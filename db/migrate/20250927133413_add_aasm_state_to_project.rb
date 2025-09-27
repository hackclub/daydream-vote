class AddAasmStateToProject < ActiveRecord::Migration[8.0]
  def change
    add_column :projects, :aasm_state, :string
  end
end
