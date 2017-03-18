module HackerOne
  module Client
    class Weakness
      class << self
        def extract_cwe_number(cwe)
          fail StandardError::ArgumentError unless cwe.upcase.start_with?('CWE-')

          cwe.split('CWE-').last.to_i
        end
      end

      OWASP_TOP_10_2013_TO_CWE = {
        'A1-Injection' => [77, 78, 88, 89, 90, 91, 564],
        'A2-AuthSession' =>
          [287, 613, 522, 256, 384, 472, 346, 441, 523, 620, 640, 319, 311],
        'A3-XSS' => [79],
        'A4-IDOR' => [639, 99, 22],
        'A5-SecurityMisconfiguration' => [16, 2, 215, 548, 209],
        'A6-DataExposure' => [312, 319, 310, 326, 320, 311, 325, 328, 327],
        'A7-MissingAccessControl' => [285, 287],
        'A8-CSRF' => [352, 642, 613, 346, 441],
        'A9-ComponentsWithKnownVulnerabilities' => [],
        'A10-Redirects' => [601],
      }.freeze

      OWASP_DEFAULT = 'A0-Other'.freeze

      def initialize(weakness)
        @attributes = weakness
      end

      def to_owasp
        OWASP_TOP_10_2013_TO_CWE.map do |owasp, cwes|
          owasp if cwes.include?(self.class.extract_cwe_number(to_cwe))
        end.compact.first || OWASP_DEFAULT
      end

      def to_cwe
        @attributes[:external_id]
      end
    end
  end
end
