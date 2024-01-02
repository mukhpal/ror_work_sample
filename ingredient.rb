class Ingredient < ApplicationRecord
  validates :name, presence: true
  validates :aisle, presence: true

  has_many :recipe_ingredients, dependent: :destroy
  has_many :recipes, through: :recipe_ingredients

  scope :without_ids, -> (ids) { where.not(id: ids) }

  def measurements
    JSON.parse(measurement_sizes).sort
  end

  def self.import(file)
    transaction do
      csv_text = File.read(file.path)
      csv_text.gsub! "\r", ''
      ingredients_ids = []
      CSV.parse(csv_text, headers: true, skip_blanks: true, row_sep: "\n") do |ingredient|
        item = find_or_initialize_by(name: ingredient['GroceryItemName'].to_s.downcase)
        item.update!(aisle: ingredient['Aisle'])
        ingredients_ids << item.id
      end
      without_ids(ingredients_ids).destroy_all
    end
    { success: 'Ingredients has been updated successfully.' }
    rescue ArgumentError, CSV::MalformedCSVError, ActiveRecord::ValueTooLong, ActiveRecord::RecordInvalid => exception
      { error: "#{exception.message}. Please verify your file again." }
  end
end
