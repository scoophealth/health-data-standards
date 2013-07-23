require 'test_helper'

class VitalSignImporterTest < MiniTest::Unit::TestCase

  def test_vital_sign_importing
    doc = Nokogiri::XML(File.new('test/fixtures/JOHN_CLEESE_1_25091940.xml'))
    doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
    pi = HealthDataStandards::Import::E2E::PatientImporter.instance
    patient = pi.parse_e2e(doc)

    vital_sign = patient.vital_signs[0]

    assert_equal Time.gm(2013,5,8,12,0,0).to_i, vital_sign.time
    assert_equal "Blood Pressure", vital_sign.description
    assert_equal "130/85 (sitting position)", vital_sign.free_text
  end

end