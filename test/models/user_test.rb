# == Schema Information
#
# Table name: users
#
#  id                  :bigint           not null, primary key
#  email               :string           default(""), not null
#  provider            :string
#  uid                 :string
#  remember_created_at :datetime
#  sign_in_count       :integer          default(0), not null
#  current_sign_in_at  :datetime
#  last_sign_in_at     :datetime
#  current_sign_in_ip  :inet
#  last_sign_in_ip     :inet
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  settings            :string
#

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
