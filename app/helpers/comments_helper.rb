module CommentsHelper
  def image_not_missing?(image)
    image.url != '/images/original/missing.png'
  end
end
