require 'spec_helper'

describe Travis::Addons::Billing::Mailer::BillingMailer do
  describe '#charge_failed' do
    subject(:mail) { described_class.charge_failed([recipient], subscription, owner, charge, event, invoice, cc_last_digits) }

    let(:recipient) { 'sergio@travis-ci.com' }
    let(:subscription) {{company: 'Ruby Monsters', first_name: 'Tessa', last_name: 'Schmidt', address: 'Rigaer Str.', city: 'Berlin', state: 'Berlin', post_code: '10000', country: 'Germany', vat_id: 'DE123456789'}}
    let(:owner) {{name: 'Ruby Monsters', login: 'rubymonsters', vcs_type: 'GithubUser', owner_type: 'User'}}
    let(:invoice) {{ pdf_url: pdf_url, amount_due: 999, current_period_start: Time.now.to_i, current_period_end: Time.now.to_i, amount: 999, created_at: Time.now.to_s, invoice_id: 'TP123', plan: 'Startup'}}
    let(:real_pdf_url) {  'http://invoices.travis-ci.dev/invoices/123'}
    let(:pdf_url) { real_pdf_url }
    let(:filename) { 'TP123.pdf' }
    let(:cc_last_digits) { '1234' }
    let(:charge) { nil}
    let(:event) { {}}

    let(:html) { mail.body.raw_source }

    before do
      stub_request(:get, real_pdf_url).to_return(status: 200, body: "% PDF", headers: {'Content-Disposition' => "attachment; filename=\"#{filename}\""})
    end

    it 'is contains proper image urls' do
      expect(html).to include('https://s3.amazonaws.com/travis-email-assets/travis_ci_logo.png')
      expect(html).to include('https://s3.amazonaws.com/travis-email-assets/x-logo-black.png')
    end

  end
end
