defmodule AttachmentTemplate do
  defstruct type: "generic", title: "", image_url: "", subtitle: "", buttons: []
  def setTitle(template, title) do
    %AttachmentTemplate{template | title: title}
  end

  def setSubtitle(template, subtitle) do
    %AttachmentTemplate{template | subtitle: subtitle}
  end

  def setImageUrl(template, image_url) do
    %AttachmentTemplate{template | image_url: image_url}
  end

  def setButtons(template, buttons) do
    %AttachmentTemplate{template | buttons: buttons}
  end

  def getPayload(template) do
    %{
      template_type: template.type,
      elements: [
        %{
          title: "#{template.title}",
          image_url: "#{template.image_url}",
          subtitle: "#{template.subtitle}",
          buttons: template.buttons
        }
      ]

    }
  end

  def getAttachment(template) do
    %{
      attachment: %{
        type: "template",
        payload: getPayload(template)
      }
    }
  end
end
