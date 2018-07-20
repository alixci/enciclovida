class Adicional < ActiveRecord::Base

  establish_connection(:development)
  self.table_name='enciclovida.adicionales'

  belongs_to :especie
  attr_accessor :select_nom_comun, :text_nom_comun

  validates_uniqueness_of :especie_id

  # Lenguas aceptadas de NaturaLista
  LENGUAS_ACEPTADAS = %w(espanol spanish espanol_mexico huasteco maya maya_peninsular mayan_languages mazateco mixteco mixteco_de_yoloxochitl totonaco otomi nahuatl zapoteco english)
end