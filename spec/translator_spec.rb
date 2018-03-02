RSpec.describe QRB::Translator do
  describe "#translate" do
    let(:translator) { QRB::Translator.new(sql) }
    let(:sql) do
      <<-EOF
      select 
        *
      from hoges
      where
      /** a.null? */
      hoges.name = /**= a.name */
      /** end */
      and hoges.age = 23
      EOF
    end
    it "'/** */' -> '<% %>' " do
      expect(translator.translate).to eq <<-EOF
      select 
        *
      from hoges
      where
      <% a.null? %>
      hoges.name = <%= a.name %>
      <% end %>
      and hoges.age = 23
      EOF
    end
  end
end
