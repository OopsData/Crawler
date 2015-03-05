class TasksController < ApplicationController
  before_action :set_task, only: [:show, :edit, :update, :destroy,:able]

  # GET /tasks
  # GET /tasks.json
  def index
    params[:type] ||= 'video'
    page    = params[:page] || 1
    @tasks  = Task.where(type:params[:type])
    if params[:type] == 'video'
      if params[:name].present?
        @tasks = @tasks.where(title:/#{params[:name]}/)
      end    
    else
      if params[:name].present?
        @tasks = @tasks.where(keyword:/#{params[:name]}/)
      end      
    end

    if params[:start_date].present?
      @tasks = @tasks.where(:created_at.gte => Date.parse(params[:start_date]))
    end

    if params[:end_date].present?
      @tasks = @tasks.where(:created_at.lte => Date.parse(params[:end_date]))
    end
    @tasks = @tasks.asc(:created_at).page(page).per(100)
    
  end

  # GET /tasks/1
  # GET /tasks/1.json
  def show
  end

  # GET /tasks/new
  def new
    @task = Task.new
  end

  def able
    if @task.status == Task::ENABLE
      @task.update_attributes(status:Task::DISABLE)
    else
      @task.update_attributes(status:Task::ENABLE)
    end
    render :json =>{:success => true}
  end



  # POST /tasks
  # POST /tasks.json
  def create
    if params[:task][:type] == 'news'
      Rails.logger.info('---------------------')
      Rails.logger.info(params[:task].inspect)
      Rails.logger.info('---------------------')
      Task.create(type:params[:task]['type'],keyword:params[:task]['keyword'],start_date:params[:task]['start_date'],end_date:params[:task]['end_date'])
    else
      task_params[:url].split(/\r\n/).each do |ts|
        Task.gs_new(ts)
      end      
    end
    respond_to do |format|
      format.html { redirect_to root_path, notice: '任务创建成功.' }
    end
  end

  def destroy
    @task.destroy
    respond_to do |format|
      format.html { redirect_to tasks_url, notice: 'Task was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_task
      @task = Task.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def task_params
      params.require(:task).permit(:title, :url, :site, :status)
    end
end
