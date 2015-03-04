class AdministriviaController < ApplicationController

  def index
    page    = params[:page] || 1
    @administrivia  = Administrivium.all
    if params[:name].present?
      word = URI::decode(params[:name])
      @administrivia = @administrivia.where(keyword:/#{word}/)
    end

    if params[:start_date].present?
      @administrivia = @administrivia.where(:created_at.gte => Date.parse(params[:start_date]))
    end

    if params[:end_date].present?
      @administrivia = @administrivia.where(:created_at.lte => Date.parse(params[:end_date]))
    end
    @administrivia = @administrivia.asc(:created_at).page(page).per(50)

  end

  def destroy
    @administrivium.destroy
    respond_to do |format|
      format.html { redirect_to administrivia_url, notice: 'Administrivium was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
end
