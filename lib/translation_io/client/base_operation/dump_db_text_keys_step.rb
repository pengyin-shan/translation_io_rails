module TranslationIO
  class Client
    class BaseOperation
      class DumpDBTextKeysStep
        def initialize(db_fields)
          @db_fields         = db_fields
        end

        def run
          if @db_fields
            TranslationIO.info "Extracting source fields from database."
            TranslationIO.info "debug 1"
            FileUtils.mkdir_p(File.join('tmp', 'translation'))
            TranslationIO.info "deb"
            file_path = File.join('tmp', 'translation', 'database_strings.rb')
            File.open(file_path, 'w') do |file|
              file.puts "def fake"
              extracted_db_entries.each do |entry|
                file.puts "_(\"#{escape_entry(entry)}\")" if entry.present?
              end
              file.puts "end"
            end
          end
        end

        protected

        # Make sure we do not break fake method calls with mismatching quotes or 
        # multi-line strings
        def escape_entry(entry)          
          entry.gsub('"', '\"')
               .gsub("\r\n", '\r\n')
               .gsub("\n", '\n')
        end

        def extracted_db_entries
          entries = []
          TranslationIO.info "keys " + @db_fields.keys.to_s
          @db_fields.keys.each do |table_name|
            TranslationIO.info "table name is " + table_name.to_s
            table = table_name.constantize
            @db_fields[table_name].each do |column_name|
              db_strings = if table_name == 'phases' then table.unscoped.distinct.pluck(column_name) else table.distinct.pluck(column_name) end
              entries += db_strings
            end
          end

          TranslationIO.info "#{entries.size} entries found in the database", 2, 2
          entries
        end

      end
    end
  end
end
