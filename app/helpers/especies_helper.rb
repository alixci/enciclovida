module EspeciesHelper

  def tituloNombreCientifico(taxon, params={})
    if I18n.locale.to_s == 'es_cientifico'
      if params[:title]
        "#{taxon.categoria_taxonomica.nombre_categoria_taxonomica} #{Especie::ESTATUSES_SIMBOLO[taxon.estatus]} #{taxon.nombre_cientifico} #{taxon.nombre_autoridad}".html_safe
      elsif params[:context]
        "#{taxon.categoria_taxonomica.nombre_categoria_taxonomica} #{Especie::ESTATUSES_SIMBOLO[taxon.estatus]} #{view_context.link_to(taxon.nombre_cientifico, "/especies/#{taxon.id}")} #{taxon.nombre_autoridad}".html_safe
      elsif params[:link]
        "#{taxon.categoria_taxonomica.nombre_categoria_taxonomica} #{Especie::ESTATUSES_SIMBOLO[taxon.estatus]} #{link_to(taxon.nombre_cientifico, "/especies/#{taxon.id}")} #{taxon.nombre_autoridad}".html_safe
      else
        'Ocurrio un error en el t&iacute;tulo'.html_safe
      end
    else
      if params[:title]
        "#{taxon.categoria_taxonomica.nombre_categoria_taxonomica} #{Especie::ESTATUSES_SIMBOLO[taxon.estatus]} #{taxon.nombre_cientifico}".html_safe
      elsif params[:context]
        "#{taxon.categoria_taxonomica.nombre_categoria_taxonomica} #{Especie::ESTATUSES_SIMBOLO[taxon.estatus]} #{view_context.link_to(taxon.nombre_cientifico, "/especies/#{taxon.id}")}".html_safe
      elsif params[:link]
        "#{taxon.categoria_taxonomica.nombre_categoria_taxonomica} #{Especie::ESTATUSES_SIMBOLO[taxon.estatus]} #{link_to(taxon.nombre_cientifico, "/especies/#{taxon.id}")}".html_safe
      else
        'Ocurrio un error en el t&iacute;tulo'.html_safe
      end
    end
  end

  def enlacesDelArbol(taxon, conClick=nil)
    nodos="<ul><li id='nodo_#{taxon.id}' class='links_arbol'>#{view_context.link_to('±', '', :id => "link_#{taxon.id}", :class => :sub_link_taxon, :onclick => 'return despliegaOcontrae(this.id);')} #{tituloNombreCientifico(taxon, :context => true)}</li>"
    conClick.present? ? nodos[4..-1] : nodos
  end

  def enlacesDeTaxonomia(taxa, nuevo=false)
    enlaces ||="<table width=\"1000\" id=\"enlaces_taxonomicos\"><tr><td>"

    taxa.ancestor_ids.push(taxa.id).each do |ancestro|
      if (taxa.id).equal?(ancestro)
        if nuevo
          e=Especie.find(ancestro)
          enlaces+="#{link_to(e.nombre, e)} (#{e.categoria_taxonomica.nombre_categoria_taxonomica}) > ?   "
        else
          enlaces+="#{taxa.nombre} (#{taxa.categoria_taxonomica.nombre_categoria_taxonomica}) > "
        end
      else
        e=Especie.find(ancestro)
        enlaces+="#{link_to(e.nombre, e)} (#{e.categoria_taxonomica.nombre_categoria_taxonomica}) > "
      end
    end
    "#{enlaces[0..-3]}</td></tr></table>".html_safe
  end

  def arbolTaxonomico
    arbolCompleto ||="<ul class=\"nodo_mayor\">"
    reino=CategoriaTaxonomica.where(:nivel1 => 1, :nivel2 => 0, :nivel3 => 0, :nivel4 => 0).first

    Especie.where(:categoria_taxonomica_id => reino).each do |t|
      arbolCompleto+=enlacesDelArbol(t)
    end
    arbolCompleto+='</ul>'
  end

  def opcionesListas(listas)
    opciones ||=''
    listas.each do |lista|
      opciones+="<option value='#{lista.id}'>#{view_context.truncate(lista.nombre_lista, :length => 40)} (#{lista.cadena_especies.present? ? lista.cadena_especies.split(',').count : 0 } taxones)</option>"
    end
    opciones
  end

  def accionesEnlaces(modelo, accion, index=false)
    case accion
      when 'especies'
        "#{link_to(image_tag('app/32x32/zoom.png'), modelo)}
        #{link_to(image_tag('app/32x32/edit.png'), "/#{accion}/#{modelo.id}/edit")}
        #{link_to(image_tag('app/32x32/trash.png'), "/#{accion}/#{modelo.id}", method: :delete, data: { confirm: "¿Estás seguro de eliminar esta #{accion.singularize}?" })}"
      when 'listas'
        index ?
            "#{link_to(image_tag('app/32x32/full_page.png'), modelo)}
            #{link_to(image_tag('app/32x32/edit_page.png'), "/#{accion}/#{modelo.id}/edit")}
            #{link_to(image_tag('app/32x32/download_page.png'), "/listas/#{modelo.id}.csv")}
            #{link_to(image_tag('app/32x32/delete_page.png'), "/#{accion}/#{modelo.id}", method: :delete, data: { confirm: "¿Estás seguro de eliminar esta #{accion.singularize}?" })}" :
            "#{link_to(image_tag('app/32x32/full_page.png'), modelo)}
            #{link_to(image_tag('app/32x32/edit_page.png'), "/#{accion}/#{modelo.id}/edit")}
            #{link_to(image_tag('app/32x32/add_page.png'), new_lista_url)}
            #{link_to(image_tag('app/32x32/download_page.png'), "/listas/#{modelo.id}.csv")}
            #{link_to(image_tag('app/32x32/delete_page.png'), "/#{accion}/#{modelo.id}", method: :delete, data: { confirm: "¿Estás seguro de eliminar esta #{accion.singularize}?" })}"
    end
  end

  def busquedas(iterador)
    opciones=''
    iterador.each do |valor, nombre|
      opciones+="<option value=\"#{valor}\">#{nombre}</option>"
    end
    opciones
  end

  def checkboxTipoDistribucion
    checkBoxes=''
    contador=0
    TipoDistribucion.all.order('descripcion ASC').each do |tipoDist|
      checkBoxes+='<br>' if contador == 3    #para darle un mejor espacio
      checkBoxes+="#{check_box_tag("tipo_distribucion_#{tipoDist.id}", tipoDist.id.to_s, false, :class => :busqueda_atributo_checkbox)} #{tipoDist.descripcion}&nbsp;&nbsp;"
      contador+=1
    end
    checkBoxes.html_safe
  end

  def checkboxValidoSinonimo(tipoBusqueda)
    checkBoxes=''
    Especie::ESTATUSES.each do |e|
      checkBoxes+="#{check_box_tag("estatus_#{tipoBusqueda}_#{e.first}", e.first, false, :class => :busqueda_atributo_checkbox_estatus)} #{e.last}&nbsp;&nbsp;"
    end
    checkBoxes.html_safe
  end

  def dameRegionesNombresBibliografia(especie)
    distribuciones=nombresComunes=tipoDistribuciones=''
    distribucion={}
    tipoDist=[]
    biblioCont=1

    especie.especies_regiones.each do |e|
      tipoDist << e.tipo_distribucion.descripcion if e.tipo_distribucion_id.present?

      if e.tipo_distribucion_id.present?
        tipo_reg=e.region.tipo_region
        niveles="#{tipo_reg.nivel1}#{tipo_reg.nivel2}#{tipo_reg.nivel3}"
        distribucion[niveles]=[] if distribucion[niveles].nil?

        case niveles
          when '100'
            distribucion[niveles].push('<b>En todo el territorio nacional</b>')
          when '110'
            distribucion[niveles].push('<b>Estatal</b>') if distribucion[niveles].empty?
            distribucion[niveles].push("<li>#{e.region.nombre_region}</li>")
          when '111'
            distribucion[niveles].push('<b>Municipal</b>') if distribucion[niveles].empty?
            distribucion[niveles].push("<li>#{e.region.nombre_region}</li>")
          when '200'
            distribucion[niveles].push("<b>#{tipo_reg.descripcion}</b>") if distribucion[niveles].empty?
            distribucion[niveles].push("<li>#{e.region.nombre_region}</li>")
          when '300'
            distribucion[niveles].push("<b>#{tipo_reg.descripcion}</b>") if distribucion[niveles].empty?
            distribucion[niveles].push("<li>#{e.region.nombre_region}</li>")
          when '400'
            distribucion[niveles].push("<b>#{tipo_reg.descripcion}</b>") if distribucion[niveles].empty?
            distribucion[niveles].push("<li>#{e.region.nombre_region}</li>")
          when '500'
            distribucion[niveles].push("<b>#{tipo_reg.descripcion}</b>") if distribucion[niveles].empty?
            distribucion[niveles].push("<li>#{e.region.nombre_region}</li>")
          when '510'
            distribucion[niveles].push("<b>#{tipo_reg.descripcion}</b>") if distribucion[niveles].empty?
            distribucion[niveles].push("<li>#{e.region.nombre_region}</li>")
          when '511'
            distribucion[niveles].push("<b>#{tipo_reg.descripcion}</b>") if distribucion[niveles].empty?
            distribucion[niveles].push("<li>#{e.region.nombre_region}</li>")
        end
      end

      e.nombres_regiones.where(:region_id => e.region_id).each do |nombre|
        nomBib="#{nombre.nombre_comun.nombre_comun} (#{nombre.nombre_comun.lengua.downcase})"
        nombre.nombres_regiones_bibliografias.where(:region_id => nombre.region_id, :nombre_comun_id => nombre.nombre_comun_id).each do |biblio|
          nomBib+=" #{link_to('Bibliografía', '', :id => "link_dialog_#{biblioCont}", :onClick => 'return muestraBibliografiaNombres(this.id);', :class => 'link_azul', :style => 'font-size:11px;')}
<div id=\"biblio_#{biblioCont}\" title=\"Bibliografía\" class=\"biblio\" style=\"display: none\">#{biblio.bibliografia.cita_completa}</div>"
          biblioCont+=1
        end
        nombresComunes+="<li>#{nomBib}</li>"
      end
    end

    distribucion.each do |k, v|
      titulo=true
      v.each do |reg|
        titulo ? distribuciones+="#{reg}<ul>" : distribuciones+=reg
        titulo=false
      end
      distribuciones+='</ul>'
    end

    tipoDist.uniq.each do |d|
      tipoDistribuciones+= "<li>#{d}</li>"
    end

    {:distribuciones => distribuciones, :nombresComunes => nombresComunes, :tipoDistribuciones => tipoDistribuciones}
  end

  def dameEspecieEstatuses(taxon)
    estatuses=''

    taxon.especies_estatuses.order('estatus_id ASC').each do |estatus|
      taxSinonimo = Especie.find(estatus.especie_id2)
      next if taxSinonimo.nil?

      if taxon.estatus == 2
        estatuses+= "<li>[#{estatus.estatus.descripcion.downcase}] #{tituloNombreCientifico(taxSinonimo, :link => true)}"
        estatuses+= estatus.observaciones.present? ? "<br> <b>Observaciones: </b> #{estatus.observaciones}</li>" : '</li>'
      elsif taxon.estatus == 1 && taxon.especies_estatuses.count == 1
        estatuses+= tituloNombreCientifico(taxSinonimo, :link => true)
        estatuses+= "<br> <b>Observaciones: </b> #{estatus.observaciones}" if estatus.observaciones.present?
      else
        return '<p><strong>Existe un problema con el estatus del nombre cient&iacute;fico de este tax&oacute;n</strong></p>'
      end
    end

    if estatuses.present?
      taxon.estatus == 2 ? titulo='<strong>Bas&oacute;nimos, sin&oacute;nimos:</strong>' : titulo='<strong>Aceptado como:</strong>'
      taxon.estatus == 2 ? titulo + "<p><ul>#{estatuses}</ul></p>" : titulo + "<p>#{estatuses}</p>"
    else
      estatuses
    end
  end

  def dameCaracteristica(taxon)
    conservacion=''
    taxon.especies_catalogos.each do |e|
      titulo=Catalogo.where(:nivel1 => e.catalogo.nivel1, :nivel2 => 1).first.descripcion
      conservacion+="<li>#{e.catalogo.descripcion}<span style='font-size:9px;'> (#{titulo})</span></li>"
    end
    conservacion.present? ? "<p><strong>Caracter&iacute;stica del tax&oacute;n:</strong><ul>#{conservacion}</ul></p>" : conservacion
  end

  def dameEspecieBibliografia(taxon)
    biblio=''
    taxon.especies_bibliografias.each do |bib|
      biblio+="<p>#{bib}</p><br>"
    end
    biblio.present? ? '<b>Bibliografía</b>' : biblio
  end

  def dameDescendientesDirectos(taxon)
    hijos=''
    taxon.child_ids.each do |children|
      subTaxon=Especie.find(children)
      hijos+="<li>#{tituloNombreCientifico(subTaxon, :link => true)}</li>" if subTaxon.present?
    end
    hijos.present? ? "<fieldset><legend class='leyenda'>Descendientes directos</legend><div id='hijos'><ul>#{hijos}</div></fieldset></ul>" : hijos
  end

  def dameListas(listas)
    titulo = "<b>#{view_context.link_to(:Listas, listas_path)} de taxones</b>"
    html = if listas.nil?
             "<br><i>Debes #{view_context.link_to 'iniciar sesi&oacute;n'.html_safe, inicia_sesion_usuarios_path} para poder ver tus listas.</i>"
           elsif listas == 0
             "<br><i>A&uacute;n no has creado ninguna lista. ¿Quieres #{view_context.link_to 'crear una', new_lista_url}?</i>"
           else
             "<br><i>Puedes a&ntilde;adir taxones a m&aacute;s de una lista. (tecla Ctrl)</i><br>
              #{view_context.select_tag('listas_hidden', opcionesListas(listas).html_safe, :multiple => true, :size => (listas.length if listas.length <= 5 || 5), :style => 'width: 380px;')}<br><br>"
           end
    titulo + html
  end

  def photo_providers(licensed=false, photo_providers=nil)
    providers=CONFIG.photo_providers ||= photo_providers || %W(flickr eol wikimedia)
    html='<ul>'
    providers.each do |prov|
      prov=prov.to_s.downcase

      case prov
        when 'flickr'
          html+="<li>#{link_to("<span>De #{prov.titleize}</span>".html_safe, "##{prov}_taxon_photos")}</li>"
        when 'wikimedia'
          html+="<li>#{link_to("<span>De #{prov.titleize} Commons</span>".html_safe, "##{prov}_taxon_photos")}</li>"
        when 'eol', 'conabio'
          html+="<li>#{link_to("<span>De #{prov.upcase}</span>".html_safe, "##{prov}_taxon_photos")}</li>"
        when 'inat_obs'
          title=licensed ? "#{t(:from_licensed_site_observations, :site_name => SITE_NAME_SHORT)}" :
              "#{t(:from_your_site_observations, :site_name => SITE_NAME_SHORT)}"
          html+="<li>#{link_to("<span>#{title}</span>".html_safe, "##{prov}_taxon_photos")}</li>"
        else
          Rails.logger.info "Bad photo provider: #{prov}"
      end
    end
    "#{html}</ul>".html_safe
  end
end
