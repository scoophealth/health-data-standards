require 'test_helper'

module E2E
  class ProviderImporterTest < MiniTest::Unit::TestCase

    def setup
      Provider.all.each(&:destroy)

      @e2e_doc = Nokogiri::XML(File.new("test/fixtures/JOHN_CLEESE_1_25091940.xml"))
      @e2e_doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
      @importer = HealthDataStandards::Import::E2E::ProviderImporter.instance
    end

    def test_provider_extraction

      providers = @importer.extract_providers(@e2e_doc)

      assert_equal 28, providers.size
      #assert_equal 'xyz', "providers[25].inspect: " + providers[25].inspect

      provider_perf = providers.first
      provider1 = provider_perf.provider
      refute_nil provider1

      #assert_equal "Dr.", provider.title
      #assert_equal "Pseudo", provider.given_name
      #assert_equal "Physician-1", provider.family_name
      #assert_equal '808401234567893', provider.npi
      # assert_equal "NIST HL7 Test Laboratory", provider[:organization]
      #assert_equal "200000000X", provider.specialty

      provider_perf2 = providers.last
      provider2 = provider_perf2.provider
      refute_nil provider2

      providers.each do |provider_perf|
        assert_equal "", provider_perf.provider.title
        assert_equal "", provider_perf.provider.given_name
        #all provider_perf are LIFELABS
        assert_equal '0UoCjCo6K8lHYQK7KII0xBWisB+CjqYqxbPkLw==', provider_perf.provider.family_name
        assert_equal provider_perf.provider.family_name, provider_perf.provider.npi
        assert_equal nil, provider_perf.provider.tin
        assert_equal "", provider_perf.provider.specialty
        assert_equal nil, provider_perf.provider.phone
      end

      #assert_equal "Dr.", provider2.title
      #assert_equal "Pseudo", provider2.given_name
      #assert_equal "Physician-3", provider2.family_name
      # assert_equal "NIST HL7 Test Laboratory", provider2[:organization]
      #assert_equal "200000000X", provider2.specialty
      #assert_nil provider2.npi
      assert_equal provider2.family_name, provider2.npi
    end
    #
    # def test_encounter_provider_extraction
    #   providers = @importer.extract_providers(@doc, true)
    #   provider = providers.first
    #   refute_nil provider
    #   assert_equal "John", provider[:given_name]
    #   assert_equal "Johnson", provider[:family_name]
    #   assert_equal "808401234567893", provider[:npi]
    #   assert_equal "Family Doctors", provider[:organization]
    #   assert_equal 4084574400, provider[:start]
    #   assert_equal "+1-301-555-5555", provider[:phone]
    # end

    def test_provider_extraction_zarilla
      doc = Nokogiri::XML(File.new('test/fixtures/PITO/MZarilla.xml'))
      doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
      importer = HealthDataStandards::Import::E2E::ProviderImporter.instance

      providers = importer.extract_providers(doc)

      #TODO get Provider Importer working for M Zarilla, not currently needed
      assert_equal 0, providers.size

    end
  end
end
