Hashid::Rails.configure do |config|
  # The minimum length of generated hashids
  config.min_hash_length = 10

  # The alphabet to use for generating hashids
  config.alphabet = "abcdefghijklmnopqrstuvwxyz" \
                    "1234567890"
end