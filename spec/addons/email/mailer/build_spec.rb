# encoding: utf-8
require 'spec_helper'

describe Travis::Addons::Email::Mailer::Build do
  include Travis::Testing::Stubs

  let(:data) { Marshal.load(Marshal.dump(TASK_PAYLOAD)) }
  let(:recipients) { ['owner@example.com', 'committer@example.com', 'author@example.com'] }
  let(:broadcasts) { [{ message: 'message', category: 'announcement' }] }
  let(:email)      { described_class.finished_email(data, recipients, broadcasts) }

  before :each do
    Travis::Addons::Email.setup
    I18n.reload!
    ActionMailer::Base.delivery_method = :test
    data['commit']['author_name'] = 'まつもとゆきひろ a.k.a. Matz'
    Travis.config.build_email_footer = true
    Travis.config.email = {}
    Travis.config.assets = {}
  end

  describe 'finished build email notification' do
    describe 'with no custom from address configured' do
      before :each do
        Travis.config.email.delete(:from)
      end

      it 'has "notifications@[hostname]" as a from address' do
        expect(email.from.join).to eq('notifications@travis-ci.org')
      end
    end

    describe 'with a custom from address configured' do
      before :each do
        Travis.config.email.from = 'builds@travis-ci.org'
      end

      it 'has that address as a from address' do
        expect(email.from.join).to eq('builds@travis-ci.org')
      end
    end

    it 'delivers to the repository owner, committer and commit author' do
      expect(email).to deliver_to(recipients)
    end

    it 'is a multipart email' do
      expect(email).to be_multipart
    end

    it 'contains the expected html part' do
      expect(email.html_part.body).to include_lines(%(
        master
        Build #2 passed
        1 min and 0 sec
        まつもとゆきひろ a.k.a. Matz
        62aae5f CHANGESET →
        the commit message
        System Message
        Want to know about upcoming build environment updates?
        about Travis CI
       ))
    end

    it 'contains the expected text part' do
      expect(email.text_part.body).to include_lines(%(
        Build: #2
        Status: Passed
        Duration: 1 min and 0 sec
        Commit: 62aae5f (master)
        Author: まつもとゆきひろ a.k.a. Matz
        Message: the commit message
        View the changeset: https://github.com/svenfuchs/minimal/compare/master...develop
        View the full build log and details: https://travis-ci.org/svenfuchs/minimal/builds/#{build.id}
      ))
    end

    context 'in HTML' do
      it 'escapes newlines in the commit message' do
        data["commit"]["message"] = "bar\nbaz"
        email.deliver # inline css interceptor is called before delivery.
        expect(email.html_part.decoded).to match(%r(bar<br( ?/)?>baz)) # nokogiri seems to convert <br> to <br /> on mri, but not jruby?
      end

      it 'correctly encodes UTF-8 characters' do
        # Encode the email, then parse the encoded string as a new Mail
        h = Mail.new(email.encoded).html_part
        html = h.body.to_s
        html.force_encoding(h.charset) if html.respond_to?(:force_encoding)
        expect(html).to include("まつもとゆきひろ a.k.a. Matz")
      end

      describe 'with the footer disabled' do
        before do
          Travis.config.build_email_footer = false
        end

        after do
          Travis.config.build_email_footer = true
        end

        it "doesn't include the build footer" do
          email.deliver # inline css interceptor is called before delivery.
          expect(email.html_part.decoded).not_to match(%r(<div class="tiny-footer">))
        end
      end
    end

    describe 'broadcasts' do
      let(:broadcasts) { [{ message: 'message 1' }, { message: 'message 2' }] }

      it 'includes a the first broadcast' do
        email.deliver
        expect(email.html_part.decoded).to match(/message 1/)
      end
    end

    describe 'for a successful build' do
      before :each do
        data['build']['state'] = 'passed'
      end

      it 'subject' do
        expect(email.subject).to eq('Passed: svenfuchs/minimal#2 (master - 62aae5f)')
      end
    end

    describe 'for a broken build' do
      before :each do
        data['build']['state'] = 'failed'
      end

      it 'subject' do
        expect(email.subject).to eq('Broken: svenfuchs/minimal#2 (master - 62aae5f)')
      end
    end

    describe 'to distinguish gmail threads' do
      it 'includes an in-reply-to header' do
        expect(email.header['In-Reply-To'].value).to eq('<svenfuchs/minimal+1+passed@travis-ci.org>')
      end

      it 'allows mixing in the build state into a custom email address' do
        Travis.config.email.from = 'notifications+%s@travis-ci.org'
        expect(email.from).to include('notifications+passed@travis-ci.org')
      end
    end

    describe 'for a cron build' do
      before :each do
        data['build']['type'] = 'cron'
      end

      it 'subject' do
        expect(email.subject).to eq('[CRON] Passed: svenfuchs/minimal#2 (master - 62aae5f)')
      end
    end
  end
end
