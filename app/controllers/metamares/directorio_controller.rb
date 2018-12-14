class Metamares::DirectorioController < Metamares::MetamaresController

  before_action :authenticate_metausuario!
  before_action :set_directorio, except: [:index, :new]
  before_action  do
    tiene_permiso?('AdminMetamares')  # Minimo administrador
    es_propietario?(@directorio) || tiene_permiso?('AdminMetamaresManager')
  end

  def index
  end

  def show
  end

  def new
  end

  def edit
  end

  def create
    @directorio = Metamares::Directorio.new(directorio_params)

    respond_to do |format|
      if @directorio.save
        format.html { redirect_to @directorio, notice: 'Los datos se actualizaron exitosamente.' }
        format.json { render action: 'show', status: :created, location: @directorio }
      else
        format.html { render action: 'new' }
        format.json { render json: @estatuse.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @directorio.update(directorio_params)
        format.html { redirect_to @directorio, notice: 'Los datos se actualizaron exitosamente' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @estatuse.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @directorio.destroy
    respond_to do |format|
      format.html { redirect_to estatuses_url }
      format.json { head :no_content }
    end
  end


  private

  def directorio_params
    params.require(:metamares_directorio).permit(:cargo, :grado_academico, :tema_estudio, :linea_investigacion,
                                                 :region_estudio, :telefono, :pagina_web)
  end

  def set_directorio
    begin
      @directorio = Metamares::Directorio.find(params[:id])
    rescue
      render :_error and return
    end
  end

end
