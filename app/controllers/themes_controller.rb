class ThemesController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @theme_pages, @themes = paginate :themes, :per_page => 10
  end

  def show
    @theme = Theme.find(params[:id])
  end

  def new
    @theme = Theme.new
  end

  def create
    @theme = Theme.new(params[:theme])
    if @theme.save
      flash[:notice] = 'Theme was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @theme = Theme.find(params[:id])
  end

  def update
    @theme = Theme.find(params[:id])
    if @theme.update_attributes(params[:theme])
      flash[:notice] = 'Theme was successfully updated.'
      redirect_to :action => 'show', :id => @theme
    else
      render :action => 'edit'
    end
  end

  def destroy
    Theme.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end