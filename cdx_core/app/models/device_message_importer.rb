# Imports plain files from sync dirs
class DeviceMessageImporter

  attr_reader :pattern

  def initialize(pattern="*.csv")
    @pattern = pattern
  end

  def import_from(sync_dir)
    Rails.logger.info "#{I18n.t('device_message_importer.running_import_for')} #{sync_dir.sync_path} #{I18n.t('device_message_importer.with_pattern')} #{pattern}"
    sync_dir.each_inbox_file(@pattern, &load_file(sync_dir))
  end

  def import_single(sync_dir, filename)
    sync_dir.if_inbox_file(filename, @pattern, &load_file(sync_dir))
  end

  def load_for_device(data, device_uuid)
    device = Device.includes(:manifest, :institution, :site).find_by!(uuid: device_uuid)
    device_message = DeviceMessage.new(device: device, plain_text_data: data)

    device_message.save!
    Rails.logger.debug("#{I18n.t('device_message_importer.saved_device_message')} #{device_message.id} #{I18n.t('device_message_importer.for_device')} #{device_uuid}")

    if device_message.index_failed?
      Rails.logger.warn "#{I18n.t('device_message_importer.parsing_failed')} #{device_message.id}"
    else
      begin
        device_message.process
      rescue => ex
        device_message.record_failure ex
        device_message.save!
        Rails.logger.error("#{I18n.t('device_message_importer.error_processing_device')} #{device_message.id}: #{ex}\n #{ex.backtrace.join("\n")}")
      else
        Rails.logger.debug("#{I18n.t('device_message_importer.processed_device')} #{device_message.id}")
      end
    end
  end

  private

  def load_file(sync_dir)
    lambda do |uuid, filename|
      Rails.logger.info "#{I18n.t('device_message_importer.importing')} #{filename} #{I18n.t('device_message_importer.for_device')} #{uuid}"
      begin
        encoding = CharDet.detect(File.read(filename))
        File.open(filename, internal_encoding: 'UTF-8', external_encoding: "#{encoding['encoding']}") do |file|
          load_for_device file.read, uuid
        end
        File.delete(filename)
      rescue => ex
        Rails.logger.error "#{I18n.t('device_message_importer.error_processing')} #{filename} #{I18n.t('device_message_importer.with_encoding')} #{encoding || 'nil'} #{I18n.t('device_message_importer.for_device')} #{uuid}: #{ex}\n #{ex.backtrace.join("\n ")}"
        sync_dir.move_inbox_file_to_error(filename)
      end
    end
  end

end
