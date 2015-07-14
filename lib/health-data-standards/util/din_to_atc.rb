require 'json'

module HealthDataStandards
  module Util
    # Helper to obtain ATC code corresponding to given DIN
    class DinToAtc

      @@din2atc_dict = Hash.new

      if defined?(Rails.root)
        #file = File.read("#{Rails.root}/lib/din2atc.txt")
        #file = File.read(Rails.root.join('lib', 'din2atc.txt'))
        file = File.read(File.expand_path('../../../../',__FILE__)+'/lib/din2atc.txt')
      else
        file = File.read(File.join(File.dirname(__FILE__),'..','..','din2atc.txt'))
      end
      din2atc_array = JSON.parse(file)
      cnt_dins = 0
      cnt_missing_atc = 0
      din2atc_array.each do |x|
        @@din2atc_dict[x['din']]=x['atc']
        cnt_dins += 1
        if x['atc'] == '' or x['atc'] == 'None'
          cnt_missing_atc += 1
        end
      end
      STDOUT.puts 'DINs: ' + cnt_dins.to_s + ', DINs without ATC: ' + cnt_missing_atc.to_s

=begin
      def initialize
        file = File.read('/tmp/din2atc.txt')
        din2atc_array = JSON.parse(file)
        din2atc_array.each do |x|
          @@din2atc_dict[x['din']]=x['atc']
        end
      end
=end

      # Returns the ATC code given a DIN code
      # @param [String] din
      # @return [String] atc
      def self.atc_for(din)
        unless @@din2atc_dict
          initialize
        end
        @@din2atc_dict[din.to_s.rjust(8,'0')] || 'Unknown'
      end

      #din2atc = DinToAtc.new
      #STDERR.puts "02242362 " + self.atc_for('02242362')
      #STDERR.puts "2242362 " + self.atc_for('02242362')

    end
  end
end

