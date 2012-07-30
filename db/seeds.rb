admin = Administrator.create!(email: 'admin@campanify.it')
admin.password = "passw0rd"
admin.password_confirmation = "passw0rd"
admin.save!