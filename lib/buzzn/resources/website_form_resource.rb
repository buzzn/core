class WebsiteFormResource < Buzzn::Resource::Entity

  model WebsiteForm

  attributes  :form_name,
              :form_content,
              :comment,
              :processed

end
