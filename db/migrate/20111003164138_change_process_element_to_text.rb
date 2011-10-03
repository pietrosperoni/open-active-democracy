class ChangeProcessElementToText < ActiveRecord::Migration
  def self.up
    change_table :process_document_elements do |t|
      t.change :content, :string
      t.change :content_text_only, :string
    end
  end

  def self.down
    change_table :process_document_elements do |t|
      t.change :content, :binary
      t.change :content_text_only, :binary
    end
  end
end
