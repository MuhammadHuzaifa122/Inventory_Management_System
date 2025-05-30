class User < ApplicationRecord
  enum :role, { staff: 0, admin: 1 }

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [ :github, :google_oauth2 ]

  def self.from_omniauth(auth)
    user = where(provider: auth.provider, uid: auth.uid).first

    user ||= create!(
      provider: auth.provider,
      uid: auth.uid,
      email: auth.info.email,
      password: Devise.friendly_token[0, 20],
      name: auth.info.name
    )

    user
  end
end
