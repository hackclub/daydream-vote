class CreateProjects < ActiveRecord::Migration[8.0]
  def change
    create_table :projects do |t|
      t.string :title
      t.text :description
      t.string :itchio_url
      t.string :repo_url

      t.timestamps
    end
  end
end
