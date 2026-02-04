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

# Create a fake workshop
fake_workshop = Workshop.find_or_create_by!(slug: 'oficina-do-ze') do |w|
  w.name = "Oficina do Zé"
end

# Create a fake user
fake_user = User.find_or_initialize_by(email: "mecanico@oficina-do-ze.pt")
fake_user.password = "123123123"
fake_user.password_confirmation = "123123123"
fake_user.workshop = fake_workshop
fake_user.save!

puts "Created Admin User: #{admin_email} / password123"
puts "Created Default Workshop: #{main_workshop.name}"
puts "Created Fake Workshop: #{fake_workshop.name}"
puts "Created Fake User: #{fake_user.email} / 123123123"
