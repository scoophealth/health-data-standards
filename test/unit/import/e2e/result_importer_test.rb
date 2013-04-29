require 'test_helper'

class ResultImporterTest < MiniTest::Unit::TestCase
  def test_result_importing
    doc = Nokogiri::XML(File.new('test/fixtures/JOHN_CLEESE_1_25091940.xml'))
    doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
    pi = HealthDataStandards::Import::E2E::PatientImporter.instance
    patient = pi.parse_e2e(doc)
    patient.save!

    result = patient.results[0]
    assert_equal 'N', result.interpretation['code']
    assert_equal nil, result.interpretation['codeSystem']
  end
end