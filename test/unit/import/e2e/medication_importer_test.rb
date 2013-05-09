# Tests can be run individually using:
# bundle exec ruby -Ilib:test test/unit/import/e2e/medication_importer_test.rb
require 'test_helper'

class MedicationImporterTest < MiniTest::Unit::TestCase
  def test_medication_importing
    doc = Nokogiri::XML(File.new('test/fixtures/JOHN_CLEESE_1_25091940.xml'))
    doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
    pi = HealthDataStandards::Import::E2E::PatientImporter.instance
    patient = pi.parse_e2e(doc)

    patient.save!

    # first listed medication
    medication = patient.medications[0]
    assert_equal "TYLENOL EXTRA STRENGTH TAB 500MG", medication.description

    assert medication.codes['HC-DIN'].include? '00559407'
    assert medication.codes['whoATC'].include? 'N02BE01'

    assert_equal "500.0", medication.value['value']
    assert_equal "MG", medication.value['unit']

    assert_equal 1362441600, medication.time
    assert_equal 1362441600, medication.start_time
    assert_equal 1366761600, medication.end_time

    assert_equal 4, medication.administration_timing['frequency']['numerator']['value']
    assert_equal 1, medication.administration_timing['frequency']['denominator']['value']
    assert_equal 'd', medication.administration_timing['frequency']['denominator']['unit']

    assert_equal 'Special medication instructions to patient', medication.freeTextSig

    assert_equal '1.0', medication.dose['low']
    assert_equal '2.0', medication.dose['high']

    assert_equal 'completed', medication.statusOfMedication

    assert_equal 'PO', medication.route['code']
    assert_equal '2.16.840.1.113883.5.112', medication.route['codeSystem']
    assert_equal 'RouteOfAdministration', medication.route['codeSystemName']
    assert_equal 'PO', medication.route['displayName']

    assert_equal 'TAB', medication.product_form['code']
    assert_equal '2.16.840.1.113883.5.1127', medication.product_form['codeSystem']
    assert_equal 'TABLET', medication.product_form['displayName']


    # last listed medication
    medication = patient.medications[8]
    assert_equal "ATORVASTATIN 40MG", medication.description

    assert medication.codes['HC-DIN'].include? '02387913'
    assert medication.codes['whoATC'].include? 'C10AA05'

    assert_equal "40.0", medication.value['value']
    assert_equal "MG", medication.value['unit']

    assert_equal 1362441600, medication.time   # returns nil?
    assert_equal 1362441600, medication.start_time
    assert_equal 1367280000, medication.end_time

    assert_equal 1, medication.administration_timing['frequency']['numerator']['value']
    assert_equal 1, medication.administration_timing['frequency']['denominator']['value']
    assert_equal 'd', medication.administration_timing['frequency']['denominator']['unit']

    assert_equal '', medication.freeTextSig

    assert_equal '1.0', medication.dose['low']
    assert_equal '1.0', medication.dose['high']

    assert_equal 'completed', medication.statusOfMedication

    assert_equal 'PO', medication.route['code']
    assert_equal '2.16.840.1.113883.5.112', medication.route['codeSystem']
    assert_equal 'RouteOfAdministration', medication.route['codeSystemName']
    assert_equal 'PO', medication.route['displayName']

    assert_equal 'TAB', medication.product_form['code']
    assert_equal '2.16.840.1.113883.5.1127', medication.product_form['codeSystem']
    assert_equal 'TABLET', medication.product_form['displayName']
  end
end
