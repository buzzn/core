require 'net/http'

module Buzzn

  class MailSendError < StandardError
  end

  module Workers
    class MailWorker

      include Sidekiq::Worker

      def perform(from, to, subject, text, bcc, html)
        case Import.global('config.mail_backend')
        when 'smtp'
          # not implemented yet
          nil
        when 'mailgun'
          api_key = Import.global('config.mailgun_api_key')
          mailgun_domain = Import.global('config.mailgun_domain')
          form_data = {
            'from' => from,
            'to' => to,
            'subject' => subject,
            'text' => text,
          }
          unless bcc.nil?
            form_data['bcc'] = bcc
          end
          unless html.nil?
            form_data['html'] = html
          end

          uri = URI.parse("https://api.mailgun.net/v3/#{mailgun_domain}/messages")
          req = Net::HTTP::Post.new(uri)
          req.basic_auth 'api', api_key
          req.set_form_data(form_data)
          opts = { use_ssl: uri.scheme == 'https'}
          res = Net::HTTP.start(uri.hostname, uri.port, opts) do |http|
            http.use_ssl = true
            http.request(req)
          end

          case res
          when Net::HTTPSuccess, Net::HTTPRedirection
            # done
            nil
          else
            raise MailSendError.new res.body
          end
        when 'noop'
          # do nothing
          nil
        end
      end

    end
  end

end
