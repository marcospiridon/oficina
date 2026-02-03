class Admin::WorkshopsController < Admin::ApplicationController
  def index
    @workshops = Workshop.all
  end

  def new
    @workshop = Workshop.new
  end

  def create
    @workshop = Workshop.new(workshop_params)
    if @workshop.save
      redirect_to admin_workshops_path, notice: "Workshop created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @workshop = Workshop.find(params[:id])
  end

  def update
    @workshop = Workshop.find(params[:id])
    if @workshop.update(workshop_params)
      redirect_to admin_workshops_path, notice: "Workshop updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    Workshop.find(params[:id]).destroy
    redirect_to admin_workshops_path, notice: "Workshop deleted."
  end

  private

  def workshop_params
    params.require(:workshop).permit(:name, :slug)
  end
end
