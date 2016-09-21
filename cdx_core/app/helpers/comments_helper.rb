module CommentsHelper
  def image_present?(image)
    image.url != '/images/original/missing.png'
  end
end
