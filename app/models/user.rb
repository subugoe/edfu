class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable, :registerable, :trackable, :registerable
  #devise :database_authenticatable, :recoverable, :rememberable, :validatable #, :registerable, :confirmable
  devise :database_authenticatable, :recoverable, :rememberable, :validatable

end
