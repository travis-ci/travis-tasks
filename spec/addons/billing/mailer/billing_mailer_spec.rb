require 'spec_helper'

describe Travis::Addons::Billing::Mailer::BillingMailer do
  describe '#invoice_payment_succeeded' do
    subject(:mail) { described_class.invoice_payment_succeeded([recipient], subscription, owner, charge, event, invoice, cc_last_digits) }

    let(:recipient) { 'sergio@travis-ci.com' }
    let(:subscription) {{company: 'Ruby Monsters', first_name: 'Tessa', last_name: 'Schmidt', address: 'Rigaer Str.', city: 'Berlin', state: 'Berlin', post_code: '10000', country: 'Germany', vat_id: 'DE123456789'}}
    let(:owner) {{name: 'Ruby Monsters', login: 'rubymonsters'}}
    let(:invoice) {{ pdf_url: pdf_url, amount_due: 999, current_period_start: Time.now.to_i, current_period_end: Time.now.to_i, amount: 999, created_at: Time.now.to_s, invoice_id: 'TP123', plan: 'Startup'}}
    let(:real_pdf_url) {  'http://invoices.travis-ci.dev/invoices/123'}
    let(:pdf_url) { real_pdf_url }
    let(:filename) { 'TP123.pdf' }
    let(:cc_last_digits) { '1234' }
    let(:charge) { nil}
    let(:event) { nil}

    let(:html) { Capybara.string(mail.html_part.body.to_s) }

    before do
      stub_request(:get, real_pdf_url).to_return(status: 200, body: "% PDF", headers: {'Content-Disposition' => "attachment; filename=\"#{filename}\""})
    end

    it 'is addressed to the user' do
      expect(mail.to).to eq([recipient])
    end

    it 'comes from Travis' do
      expect(mail.from).to eq(['success@travis-ci.com'])
    end

    it 'has the right subject' do
      expect(mail.subject).to eq('Travis CI: Your Invoice')
    end

    it 'shows the account name' do
      expect(html).to have_text_lines('Travis CI invoice for the account Ruby Monsters')
    end

    it 'shows who was billed' do
      expect(html).to have_text_lines(%q{
        Billed To:

        Ruby Monsters
        Tessa Schmidt
        Rigaer Str.
        Berlin Berlin 10000
        Germany
        DE123456789
      })
    end

    it 'shows the total' do
      expect(html).to have_text_lines(%q{
        Total \(In USD\)
        \$9.99
      })
    end

    it 'shows the credit card' do
      expect(html).to have_text_lines('Paid with credit card ending in 1234')
    end

    it 'contains the PDF attached' do
      expect(mail.attachments.size).to eq(1)

      attachment = mail.attachments.first

      expect(attachment.content_type).to start_with('application/pdf')
      expect(attachment.filename).to eq(filename)
      expect(attachment.body.raw_source).to start_with('% PDF')
    end

    context 'when the pdf url redirects' do
      let(:pdf_url) { 'http://redirects.dev/'}

      before do
        stub_request(:get, pdf_url).to_return(status: 301, headers: { 'Location' => real_pdf_url})
      end

      it 'still attaches the pdf' do
        expect(mail.attachments.size).to eq(1)

        attachment = mail.attachments.first

        expect(attachment.filename).to eq(filename)
      end
    end
  end
end
