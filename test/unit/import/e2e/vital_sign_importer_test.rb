require 'test_helper'

class VitalSignImporterTest < MiniTest::Unit::TestCase

  def test_vital_sign_importing
    doc = Nokogiri::XML(File.new('test/fixtures/JOHN_CLEESE_1_25091940.xml'))
    doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
    pi = HealthDataStandards::Import::E2E::PatientImporter.instance
    patient = pi.parse_e2e(doc)

    vital_sign = patient.vital_signs[0]

    #assert_equal 'xyz', vital_sign.inspect
    #assert_equal 'N', vital_sign.interpretation['code']
    #assert_equal "177", vital_sign.values.first.scalar
    #assert_equal "cm", vital_sign.values.first.units
    #assert_equal 'HITSP C80 Observation Status', vital_sign.interpretation['codeSystem']
  end

end