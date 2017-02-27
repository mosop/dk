module Dk
  abstract class Params
    macro params(fields)
      {% for key, i in fields.keys %}
        {%
          name = key.id
          t = fields[key]
        %}

        property! {{name}} : {{t}}?

        def {{name}}(value : {{t}}?)
          @{{name}} = value
          self
        end

        def self.{{name}}(value : {{t}}?)
          o = new
          o.{{name}} = value
          o
        end
      {% end %}

      def to_h
        h = {} of String => JSON::Type
        {% for key, i in fields.keys %}
          {%
            name = key.id
            json_name = name.gsub(/^_/, "").id
            t = fields[key]
          %}
          h[{{json_name.stringify}}] = {{name}} unless @{{name}}.nil?
        {% end %}
        h
      end
    end
  end
end
