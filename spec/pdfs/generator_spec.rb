describe Pdf::Generator do

  entity(:localpool) { create(:group, :localpool) }

  entity(:generator) { Pdf::Minimal.new(root: localpool) }

  context 'is stale' do

    it { expect(generator.pdf_document_stale?).to be true }

    context 'create pdf-document' do

      entity!(:pdf_document) { generator.create_pdf_document('some pdf data') }

      it { expect(pdf_document).to be_persisted }

      it { expect(pdf_document.document.read).to eq('some pdf data') }

      it { expect(generator.pdf_document_stale?).to be false }

      context 'is stale' do

        entity!(:new_data) { generator.instance_variable_set(:@data, {}) }

        it { expect(generator.pdf_document_stale?).to be true }

        context 'recreate pdf-document', :slow do

          entity!(:sleep) { sleep 1 }

          entity!(:pdf_document2) { generator.create_pdf_document('some pdf data') }

          it { expect(pdf_document2.id).not_to eq(pdf_document.id) }

          it { expect(pdf_document2.document.id).not_to eq(pdf_document.document.id) }

          it { expect(pdf_document2).to be_persisted }

          it { expect(pdf_document2.document.read).to eq('some pdf data') }

          it { expect(generator.pdf_document_stale?).to be false }

          context 'is stale' do

            entity!(:new_template) do
              template = generator.send(:template)
              attrs = template.attributes
              attrs.delete('id')
              attrs['version'] = attrs['version'] + 1
              template = Template.create(attrs)
              generator.instance_variable_set(:@template, template)
            end

            it { expect(generator.pdf_document_stale?).to be true }

            context 'recreate pdf-document' do

              entity!(:sleep2) { sleep 1 }

              entity!(:pdf_document3) { generator.create_pdf_document('some pdf data') }

              it { expect(pdf_document2.id).not_to eq(pdf_document3.id) }

              it { expect(pdf_document2.document.id).not_to eq(pdf_document3.document.id) }

              it { expect(generator.pdf_document_stale?).to be false }
            end
          end

        end

      end
    end
  end

end
