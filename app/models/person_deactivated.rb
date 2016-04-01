# == Schema Information
#
# Table name: people
#
#  id                       :integer          not null, primary key
#  email                    :string(255)
#  name                     :string(255)
#  crypted_password         :string(255)
#  password_salt            :string(255)
#  persistence_token        :string(255)
#  description              :text
#  last_contacted_at        :datetime
#  last_logged_in_at        :datetime
#  forum_posts_count        :integer          default(0), not null
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  admin                    :boolean          default(FALSE), not null
#  deactivated              :boolean          default(FALSE), not null
#  connection_notifications :boolean          default(TRUE)
#  message_notifications    :boolean          default(TRUE)
#  email_verified           :boolean
#  identity_url             :string(255)
#  phone                    :string(255)
#  first_letter             :string(255)
#  zipcode                  :string(255)
#  phoneprivacy             :boolean          default(TRUE)
#  language                 :string(255)
#  openid_identifier        :string(255)
#  perishable_token         :string(255)      default(""), not null
#  default_group_id         :integer
#  org                      :boolean          default(FALSE)
#  activator                :boolean          default(FALSE)
#  sponsor_id               :integer
#  broadcast_emails         :boolean          default(TRUE), not null
#  web_site_url             :string(255)
#  business_name            :string(255)
#  legal_business_name      :string(255)
#  business_type_id         :integer
#  title                    :string(255)
#  activity_status_id       :integer
#  fee_plan_id              :integer
#  support_contact_id       :integer
#  mailchimp_subscribed     :boolean          default(FALSE)
#  time_zone                :string(255)
#  date_style               :string(255)
#  posts_per_page           :integer          default(25)
#  stripe_id                :string(255)
#  requires_credit_card     :boolean          default(TRUE)
#  rollover_balance         :decimal(, )      default(0.0)
#  plan_started_at          :datetime
#

class PersonDeactivated < Person

end
