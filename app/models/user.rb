class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  belongs_to :workshop

  validates :system_admin, inclusion: { in: [true, false] }

  # Helper to check if user is admin
  def admin?
    system_admin
  end
end
