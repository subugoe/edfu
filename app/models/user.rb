class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable, :registerable, :trackable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
end
