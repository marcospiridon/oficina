class VehiclesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_workshop
  before_action :authorize_workshop_access!
  before_action :set_vehicle, only: [:show, :update, :destroy, :delete_attachment, :destroy_attachments, :download_all]

  def index
    if params[:query].present?
      # Search by license plate
      @vehicles = @workshop.vehicles.where("license_plate LIKE ?", "%#{params[:query].upcase}%")

      # If exact match found, redirect to show? Or just show list.
      # Requirement: "allow search... and create new vehicle"
      if @vehicles.empty?
        flash.now[:notice] = t('vehicles.not_found')
      end
    else
      @vehicles = @workshop.vehicles.order(created_at: :desc).limit(10)
    end
  end

  def new
    @vehicle = @workshop.vehicles.new
  end

  def create
    @vehicle = @workshop.vehicles.new(vehicle_params)

    if @vehicle.save
      redirect_to workshop_vehicle_path(workshop_slug: @workshop.slug, id: @vehicle.id), notice: t('vehicles.create.success')
    else
      # If it fails (e.g. duplicate), render index with errors or redirect
      redirect_to workshop_dashboard_path(workshop_slug: @workshop.slug, query: vehicle_params[:license_plate]), alert: t('vehicles.create.error', errors: @vehicle.errors.full_messages.join(', '))
    end
  end

  def show
    # @vehicle is set
  end

  def destroy
    @vehicle.destroy
    redirect_to workshop_vehicles_path(workshop_slug: @workshop.slug), notice: t('vehicles.destroy.success')
  end

  def update
    if params[:vehicle][:photos].present?
      @vehicle.photos.attach(params[:vehicle][:photos])
    end

    if params[:vehicle][:documents].present?
      @vehicle.documents.attach(params[:vehicle][:documents])
    end

    # For other attributes (like license plate), we still use update but without attachments
    # to avoid overwriting (even though attached params shouldn't be in the others if not permitted?
    # Actually, permit includes them, so we should exclude them from the update call if we attach manually)

    clean_params = vehicle_params.except(:photos, :documents)

    if @vehicle.update(clean_params)
      redirect_to workshop_vehicle_path(workshop_slug: @workshop.slug, id: @vehicle.id), notice: t('vehicles.update.success')
    else
      render :show, status: :unprocessable_entity
    end
  end

  def delete_attachment
    attachment = ActiveStorage::Attachment.find(params[:attachment_id])
    if attachment.record == @vehicle
      attachment.purge
      redirect_to workshop_vehicle_path(workshop_slug: @workshop.slug, id: @vehicle.id), notice: t('vehicles.attachments.deleted')
    else
      redirect_to workshop_vehicle_path(workshop_slug: @workshop.slug, id: @vehicle.id), alert: t('vehicles.attachments.not_found')
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to workshop_vehicle_path(workshop_slug: @workshop.slug, id: @vehicle.id), alert: t('vehicles.attachments.record_not_found')
  end

  def destroy_attachments
    if params[:attachment_ids].present?
      attachments = ActiveStorage::Attachment.where(id: params[:attachment_ids])
      attachments.each do |attachment|
        if attachment.record == @vehicle
          attachment.purge
        end
      end
      redirect_to workshop_vehicle_path(workshop_slug: @workshop.slug, id: @vehicle.id), notice: t('vehicles.attachments.selected_deleted')
    else
      redirect_to workshop_vehicle_path(workshop_slug: @workshop.slug, id: @vehicle.id), alert: t('vehicles.attachments.none_selected')
    end
  end

  def download_all
    # Zip export logic to be implemented
    # We will need a service or just do it inline for now

    filename = "vehicle_#{@vehicle.license_plate}.zip"
    temp_file = Tempfile.new(filename)

    begin
      require 'zip'

      Zip::File.open(temp_file.path, Zip::File::CREATE) do |zipfile|
        # Add Photos
        @vehicle.photos.each do |photo|
          zipfile.add("photos/#{photo.filename.to_s}", photo.service.path_for(photo.key)) if photo.persisted?
        end

        # Add Documents
        @vehicle.documents.each do |doc|
          zipfile.add("documents/#{doc.filename.to_s}", doc.service.path_for(doc.key)) if doc.persisted?
        end
      end

      # Send file
      send_file temp_file.path, type: 'application/zip', disposition: 'attachment', filename: filename
    ensure
      # temp_file.close
      # temp_file.unlink
    end
  end

  private

  def set_vehicle
    @vehicle = @workshop.vehicles.find(params[:id])
  end

  def vehicle_params
    params.require(:vehicle).permit(:license_plate, photos: [], documents: [])
  end
end
