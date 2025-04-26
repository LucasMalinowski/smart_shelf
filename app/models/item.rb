class Item < ApplicationRecord
  belongs_to :category
  has_many :user_items
  has_one_attached :image

  # after_create :create_image

  def create_image
    response = image_request
    if response["created"].present?
      image.attach(io: StringIO.new(Base64.decode64(response.dig('data').first.dig("b64_json"))),
                   filename: "#{name.parameterize.underscore}.jpg",
                   content_type: "image/jpeg")
    else
      Rails.logger.error "Failed to generate image for #{name}: #{response['error']}"
    end
  rescue => e
    Rails.logger.error "Error attaching image for #{name}: #{e.message}"
  end

  def image_request(args: nil)
    request = Faraday.post(
      "https://api.openai.com/v1/images/generations",
      {
        prompt: "Generate a High Quality, white background, 4k image of '#{name}' (#{category.name}) in a realistic style to be used in a storage system.
           The image should be clear and detailed, showcasing the item in a way that highlights its features.
           The image should be suitable for use in a grocery list application.
           #{args.nil? ? '' : args}
        ",
        model: 'dall-e-2',
        size: '256x256',
        response_format: 'b64_json',
      }.to_json,
      {
        'Authorization' => "Bearer #{Rails.application.credentials.openai[:api_key]}",
        'Content-Type' => 'application/json'
      }
    )

    JSON.parse(request.body)
  end
end
