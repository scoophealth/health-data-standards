require 'test_helper'

module E2E
  class ImmunizationImporterTest < MiniTest::Unit::TestCase
    def test_immunization_importing
      doc = Nokogiri::XML(File.new('test/fixtures/JOHN_CLEESE_1_25091940.xml'))
      doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
      pi = HealthDataStandards::Import::E2E::PatientImporter.instance
      patient = pi.parse_e2e(doc)

      immunization = patient.immunizations[0]
      assert_equal false, immunization.nil?
      assert_equal immunization.codes, {"whoATC"=>["J07CA01"]}
      assert_equal 'Td', immunization.description
      assert_equal Time.gm(2012,9,1).to_i, immunization.start_time
      #assert immunization.codes['CVX'].include? '88'
      #assert immunization.codes['CVX'].include? '111'

      immunization = patient.immunizations[1]
      assert_equal false, immunization.nil?
      assert_equal immunization.codes, {"whoATC"=>["J07BB01"]}
      assert_equal 'Flu', immunization.description
      assert_equal Time.gm(2009,2,1).to_i, immunization.start_time
      #assert_equal false, immunization.refusal_ind

      immunization = patient.immunizations[2]
      assert_equal false, immunization.nil?
      assert_equal immunization.codes, {"whoATC"=>["J07AL02"]}
      assert_equal 'Pneumovax', immunization.description
      assert_equal Time.gm(2012,10,31).to_i, immunization.start_time

      #immunization = patient.immunizations[3]
      #assert_equal true, immunization.refusal_ind
      #assert_equal 'PATOBJ', immunization.refusal_reason['code']

      #assert_equal immunization.performer.given_name, 'FirstName'
      #assert_equal '100 Bureau Drive', immunization.performer.addresses.first.street.first
    end

    def test_immunization_importing_zarilla
      doc = Nokogiri::XML(File.new('test/fixtures/PITO/MZarilla.xml'))
      doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
      pi = HealthDataStandards::Import::E2E::PatientImporter.instance
      patient = pi.parse_e2e(doc)

      immunization = patient.immunizations[0]
      assert_equal false, immunization.nil?
      assert_equal immunization.codes, {"Unknown"=>["NA"]}
      assert_equal 'Rotavirus (oral)', immunization.description
      assert_equal Time.gm(2012,4,17).to_i, immunization.time
      #assert immunization.codes['CVX'].include? '88'
      #assert immunization.codes['CVX'].include? '111'

      immunization = patient.immunizations[1]
      assert immunization.nil? == false
      assert_equal immunization.codes, {"Unknown"=>["NA"]}
      assert immunization.description == 'Pentacel'
      assert_equal Time.gm(2014,3,10).to_i, immunization.time

      immunization = patient.immunizations[2]
      assert immunization.nil? == false
      assert_equal immunization.codes, {"Unknown"=>["NA"]}
      assert immunization.description == 'Varicella Zoster'
      assert_equal Time.gm(2011,6,21).to_i, immunization.time

    end

    def test_time_null_flavours
      doc = Nokogiri::XML(File.new('test/fixtures/PITO/MZarilla3.xml'))
      doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
      pi = HealthDataStandards::Import::E2E::PatientImporter.instance
      patient = pi.parse_e2e(doc)

      immunization = patient.immunizations[0]
      assert_nil immunization.start_time  
      assert_nil immunization.time  
    end
  end
end