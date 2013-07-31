require 'test_helper'

module E2E
class ImmunizationImporterTest < MiniTest::Unit::TestCase
  def test_immunization_importing
    doc = Nokogiri::XML(File.new('test/fixtures/JOHN_CLEESE_1_25091940.xml'))
    doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
    pi = HealthDataStandards::Import::E2E::PatientImporter.instance
    patient = pi.parse_e2e(doc)

    immunization = patient.immunizations[0]
    assert immunization.nil? == false
    assert immunization.codes == {"Unknown"=>["NA"]}
    assert immunization.description == 'Td'
    assert_equal Time.gm(2012,9,1).to_i, immunization.time
    #assert immunization.codes['CVX'].include? '88'
    #assert immunization.codes['CVX'].include? '111'

    immunization = patient.immunizations[1]
    assert immunization.nil? == false
    assert immunization.codes == {"Unknown"=>["NA"]}
    assert immunization.description == 'Pneumovax'
    assert_equal Time.gm(2009,2,1).to_i, immunization.time
    #assert_equal false, immunization.refusal_ind

    immunization = patient.immunizations[2]
    assert immunization.nil? == false
    assert immunization.codes == {"Unknown"=>["NA"]}
    assert immunization.description == 'Flu'
    assert_equal Time.gm(2012,10,31).to_i, immunization.time

    #immunization = patient.immunizations[3]
    #assert_equal true, immunization.refusal_ind
    #assert_equal 'PATOBJ', immunization.refusal_reason['code']

    #assert_equal immunization.performer.given_name, 'FirstName'
    #assert_equal '100 Bureau Drive', immunization.performer.addresses.first.street.first
  end
end
end