# Create a default workshop
main_workshop = Workshop.find_or_create_by!(slug: 'main-workshop') do |w|
  w.name = "Main Headquarters"
end

# Create a System Admin
admin_email = "admin@example.com"
admin = User.find_or_initialize_by(email: admin_email)
admin.password = "password123"
admin.password_confirmation = "password123"
admin.workshop = main_workshop
admin.system_admin = true
admin.save!

puts "Created Admin User: #{admin_email} / password123"
puts "Created Default Workshop: #{main_workshop.name}"
