defmodule HealthWebWeb.CoreComponents do
  @moduledoc """
  Only provides core UI components. For particular UI components, please prefer to `HealthWebWeb.UiComponents`

  The components in this module use Tailwind CSS, a utility-first CSS framework.
  See the [Tailwind CSS documentation](https://tailwindcss.com) to learn how to
  customize the generated components in this module.

  Icons are provided by [heroicons](https://heroicons.com), using the
  [heroicons_elixir](https://github.com/mveytsman/heroicons_elixir) project.
  """
  use Phoenix.Component

  alias Phoenix.LiveView.JS
  import HealthWebWeb.Gettext

  @doc """
  Renders a modal.

  ## Examples

      <.modal id="confirm-modal">
        Are you sure?
        <:confirm>OK</:confirm>
        <:cancel>Cancel</:cancel>
      </.modal>

  JS commands may be passed to the `:on_close` and `on_confirm` attributes
  for the caller to react to each button press, for example:

      <.modal id="confirm">
        Are you sure you?
      </.modal>
  """
  attr(:id, :string, required: true)
  attr(:show, :boolean, default: false)
  attr(:on_close, JS, default: %JS{})
  attr(:align, :string, default: nil, values: [nil, "center"])
  attr(:show_close, :boolean, default: true)

  attr(:closeable, :any,
    default: :close_button,
    values: [true, false, :close_button],
    doc: """
      Set :closeable to `true` to enable background click and close button.
      Set to :close_button to only enable close button. Default is to `:close_button`
    """
  )

  attr(:width, :string, default: "md", values: ~w"smb sm md lg xl 2xl")
  attr(:height, :string, default: "base", values: ~w"base full pdf")

  slot(:inner_block, required: true)
  slot(:title)
  slot(:subtitle)
  slot(:footer)
  slot(:icon)

  slot(:action) do
    attr(:on_click, JS)
    attr(:type, :string)
    attr(:color, :string)
    attr(:size, :string)
    attr(:disabled, :boolean)
    attr(:"phx-disable-with", :string)
  end

  def modal(assigns) do
    ~H"""
    <div id={@id} phx-mounted={@show && show_modal(@id)} phx-remove={hide_modal(@id)} class="modal">
      <div id={"#{@id}-bg"} class="modal__bg" aria-hidden="true"  />
      <div
        class="fixed inset-0"
        aria-labelledby={"#{@id}-title"}
        aria-describedby={"#{@id}-description"}
        role="dialog"
        aria-modal="true"
        tabindex="0"
      >
        <div class="modal__wrapper">
          <div class={[
            "modal__body",
            "modal__body--#{assigns[:size] || @width}",
            if(assigns[:height], do: "modal__body--#{@height}")
          ]}>
            <div
              id={"#{@id}-container"}
              phx-mounted={@show && show_modal(@id)}
              phx-window-keydown={@closeable == true && hide_modal(@on_close, @id)}
              phx-click-away={@closeable == true && hide_modal(@on_close, @id)}
              phx-key="escape"
              class={[
                "hidden relative bg-white transition w-full flex-auto",
                if(@height == "full") do "rounded-none" else "rounded-2xl" end
              ]}
            >
              <div
                id={"#{@id}-content"}
                class={[
                  "modal__content",
                  if(assigns[:align], do: "modal__content--#{@align}")
                ]}
              >
                <button
                  :if={@show_close}
                  tabindex="-1"
                  phx-click={hide_modal(@on_close, @id)}
                  type="button"
                  class="modal__content__close"
                  aria-label="close"
                >
                  <svg
                    width="20"
                    height="20"
                    viewBox="0 0 20 20"
                    fill="none"
                    xmlns="http://www.w3.org/2000/svg"
                  >
                    <path
                      d="M15 5L5 15M5 5L15 15"
                      stroke="#525252"
                      stroke-width="2"
                      stroke-linecap="round"
                      stroke-linejoin="round"
                    />
                  </svg>
                </button>

                <header :if={@title != []}>
                  <div :if={@icon != []} class="mb-4">
                    <%= render_slot(@icon) %>
                  </div>
                  <h2 id={"#{@id}-title"} class="modal__title">
                    <%= render_slot(@title) %>
                  </h2>
                  <div :for={subtitle <- @subtitle}>
                    <%= render_slot(subtitle) %>
                  </div>
                </header>
                <div class="modal__inner">
                  <%= render_slot(@inner_block) %>
                </div>

                <footer :if={not Enum.empty?(@footer) || not Enum.empty?(@action)}>
                  <.button
                    :for={action <- @action}
                    type={Map.get(action, :type)}
                    color={Map.get(action, :color)}
                    size={Map.get(action, :size)}
                    disabled={Map.get(action, :disabled)}
                    phx-click={Map.get(action, :on_click, %JS{})}
                  >
                    <%= render_slot(action) %>
                  </.button>
                  <%= render_slot(@footer) %>
                </footer>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @doc """
  Renders flash notices.

  ## Examples

      <.flash kind={:info} flash={@flash} />
      <.flash kind={:info} phx-mounted={show("#flash")}>Welcome Back!</.flash>
  """
  attr(:id, :string, default: "flash", doc: "the optional id of flash container")
  attr(:flash, :map, default: %{}, doc: "the map of flash messages to display")
  attr(:title, :string, default: nil)

  attr(:kind, :atom,
    values: [:success, :info, :error, :warning],
    doc: "used for styling and flash lookup"
  )

  attr(:autoshow, :boolean, default: true, doc: "whether to auto show the flash on mount")
  attr(:close, :boolean, default: true, doc: "whether the flash can be closed")
  attr(:rest, :global, doc: "the arbitrary HTML attributes to add to the flash container")

  slot(:inner_block, doc: "the optional inner block that renders the flash message")

  def flash(assigns) do
    ~H"""
    <div
      :if={msg = render_slot(@inner_block) || Phoenix.Flash.get(@flash, @kind)}
      id={@id}
      phx-mounted={@autoshow && show("##{@id}")}
      role="alert"
      class="core_flash"
      {@rest}
    >
      <div
        id={"#{@id}-bg"}
        class="core_flash__bg"
        phx-click={JS.push("lv:clear-flash", value: %{key: @kind}) |> hide("##{@id}")}
      />
      <div
        class="core_flash__content core_flash__content--sm"
        phx-click={JS.push("lv:clear-flash", value: %{key: @kind}) |> hide("##{@id}")}
      >
        <div class="core_flash__body">
          <div class="core_flash__close">
            <button tabindex="10" type="button" aria-label="close">
              <Heroicons.x_mark solid class="h-5 w-5" />
            </button>
          </div>

          <div :if={@title} class={["core_flash__content__inner"]}>
            <Heroicons.check_circle :if={@kind == :success} mini class="text-Brand-MG" />
            <Heroicons.information_circle :if={@kind == :info} mini class="text-sky-500" />
            <Heroicons.exclamation_triangle :if={@kind == :warning} mini class="text-yellow-500" />
            <Heroicons.exclamation_circle :if={@kind == :error} mini class="text-red-500" />
            <h4 class={[
              "core_flash__content__title",
              @kind == :success && "text-Brand-MG",
              @kind == :info && "text-sky-500",
              @kind == :error && "p-3 text-red-500",
              @kind == :warning && "p-3 text-yellow-500"
            ]}>
              <%= case @kind do %>
                <% :success -> %>
                  Thành công
                <% :info -> %>
                  Thông tin
                <% :error -> %>
                  Lỗi
                <% :warning -> %>
                  Cảnh báo
                <% _ -> %>
              <% end %>
            </h4>
            <%= msg %>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr(:flash, :map, required: true, doc: "the map of flash messages")

  def flash_group(assigns) do
    ~H"""
    <.flash kind={:info} title="Success!" flash={@flash} />
    <.flash kind={:error} title="Error!" flash={@flash} />
    <%!-- <.flash
      id="disconnected"
      kind={:error}
      title="We can't find the internet"
      close={false}
      autoshow={false}
      phx-disconnected={show("#disconnected")}
      phx-connected={hide("#disconnected")}
    >
      Attempting to reconnect <.spinner />
    </.flash> --%>
    """
  end

  @doc """
  Renders a button.

  ## Examples

      <.button>Send!</.button>
      <.button phx-click="go" class="ml-2">Send!</.button>
  """
  attr(:type, :string, default: "button", values: ~w"submit button reset")
  attr(:class, :string, default: nil)
  attr(:style, :string, default: nil)

  attr(:color, :string,
    default: nil,
    values: [nil] ++ ~w"green black white grey gradient transparent brand"
  )

  attr(:rest, :global, include: ~w(disabled phx-disable-with phx-target phx-hook id))
  attr(:size, :string, default: nil, values: [nil] ++ ~w"nm sm full")

  slot(:inner_block, required: true)

  def button(assigns) do
    ~H"""
    <button
      type={@type || "button"}
      color={@color}
      class={["btn", if(@size, do: "btn--#{@size}"), @class]}
      {@rest}
      style={@style}
    >
      <%= render_slot(@inner_block) %>
    </button>
    """
  end

  attr(:class, :string, default: nil)
  attr(:style, :string, default: nil)

  attr(:color, :string,
    default: nil,
    values: [nil] ++ ~w"green black white grey gradient transparent brand"
  )

  attr(:rest, :global, include: ~w(disabled phx-disable-with phx-target phx-hook id href target))
  attr(:size, :string, default: nil, values: [nil] ++ ~w"nm sm full")

  slot(:inner_block, required: true)

  def link_redirect(assigns) do
    ~H"""
    <a color={@color} class={["btn", if(@size, do: "btn--#{@size}"), @class]} {@rest} style={@style}>
      <%= render_slot(@inner_block) %>
    </a>
    """
  end

  attr(:class, :string, default: nil)
  attr(:rest, :global)
  attr(:src, :string, default: nil)

  def icon(assigns) do
    ~H"""
    <img class={@class} {@rest} src={"/assets/images/icon/#{@src}"} />
    """
  end

  attr(:label, :string, default: nil)
  attr(:class, :string, default: nil)
  attr(:align, :string, default: nil)
  attr(:value, :string, default: nil)
  slot(:suffix_icon)

  def field_data(assigns) do
    ~H"""
    <div class={["field_data", "field_data__#{@align}"]}>
      <p class="field_data__label"><%= @label %></p>
      <p class={["field_data__value", @class]}><%= @value %> <%= render_slot(@suffix_icon) %></p>
    </div>
    """
  end

  @doc """
  Renders a data breadcrumb.

  ## Examples
      breadcrumb={[
        %{label: "Home", to: ~p"/"},
        %{label: "Inner page"}
      ]}
  """
   attr(:items, :list, default: [])
  # attr(:icon, :string, default: "true")
  slot(:inner_block)

  def breadcrumb(assigns) do
    ~H"""
    <ul class="breadcrumb">
      <li :for={item <- @items} class={item[:icon]}>
        <%= if item[:to] do %>
          <.link patch={item[:to]}>
            <svg :if={item[:icon] != false}
              xmlns="http://www.w3.org/2000/svg"
              width="20"
              height="20"
              viewBox="0 0 20 20"
              fill="none"
              class="mr-2"
            >
              <path
                fill-rule="evenodd"
                clip-rule="evenodd"
                d="M7.34727 11.2152C6.48711 10.355 6.48711 8.95241 7.34727 8.09225L11.875 3.56447C12.2005 3.23903 12.7281 3.23903 13.0536 3.56447C13.379 3.88991 13.379 4.41755 13.0536 4.74298L8.52578 9.27076C8.31649 9.48005 8.31649 9.82741 8.52578 10.0367L13.0536 14.5645C13.379 14.8899 13.379 15.4175 13.0536 15.743C12.7281 16.0684 12.2005 16.0684 11.875 15.743L7.34727 11.2152Z"
                fill="#1E293B"
              />
            </svg>
            <%= item[:label] %>
          </.link>
        <% else %>
          <span><%= item[:label] %></span>
        <% end %>
      </li>
    </ul>
    """
  end


  attr :page, :integer, default: 1
  attr(:class, :string, default: nil)
  attr(:page_end, :boolean, default: false)


  def panigation(assigns) do
    assigns =
      assign(assigns,
        next: assigns.page + 1,
        end_page: assigns.page - 1
      )
    ~H"""
      <ul class={["panigation", @class]}>
        <li :if={@page != 1} class="panigation_item" phx-click={JS.push("change_page", value: %{page: @page - 1})}>
         &lt;
        </li>
        <li :if={@page == 1} class="panigation_item active">
          <%= @page %>
        </li>
        <li :if={@page != 1  && !@page_end} class={["panigation_item active"]} phx-click={JS.push("change_page", value: %{page: @page - 1})}>
          <%= @page %>
        </li>
        <li :if={@page != 1 && @page_end} class={["panigation_item"]} phx-click={JS.push("change_page", value: %{page: @page - 1})}>
          <%= @end_page %>
        </li>
        <li :if={!@page_end} class="panigation_item 22" phx-click={JS.push("change_page", value: %{page: @page + 1})}>
          <%= @next %>
        </li>
        <li :if={@page_end} class="panigation_item active">
          <%= @page %>
        </li>
        <li :if={!@page_end} class="panigation_item" phx-click={JS.push("change_page", value: %{page: @page + 1})}>
          &gt;
        </li>
      </ul>
      """
  end

  @doc """
  Renders a header with title.
  """
  attr(:class, :string, default: nil)
  slot(:inner_block, required: true)

  def header(assigns) do
    ~H"""
    <header class={@class}>
      <div class="header-inner">
        <div class="flex items-center justify-between max-w-[1328px] mx-auto w-full">
          <img
            class="px-2 mx-[-8px] xl:pl-6 h-8"
            phx-click={JS.navigate("/")}
            src="/assets/images/header/logo.svg"
            alt=""
          />
          <div class="ml-auto flex items-center gap-6">
            <%= render_slot(@inner_block) %>
            <.dropdown id="open_with_kafi" placement="bottom-right" class="md:hidden">
              <:label>
                <div class="py-4 link mr-4">Mở tài khoản</div>
              </:label>
              <:item>
                <a href="https://open.kafi.vn/" target="_blank" class="block px-4 py-3 border-b border-N-200">
                  Mở tài khoản <span class="text-Brand-MG font-smb">Kafi Trade</span>
                </a>
                <a href="https://open.kafi.vn/wealth" target="_blank" class="block px-4 py-3">
                  Mở tài khoản <span class="text-Brand-MG font-smb">Kafi Wealth</span>
                </a>
              </:item>
            </.dropdown>
            <.dropdown id="login_with_kafi" placement="bottom-right" class="md:hidden">
              <:label>
                <div class="py-4 link">Đăng nhập</div>
              </:label>
              <:item>
                <a href="https://trade.kafi.vn/" target="_blank" class="block px-4 py-3 border-b border-N-200">
                  Đăng nhập <span class="text-Brand-MG font-smb">Kafi Trade</span>
                </a>
                <a href="https://wealth.kafi.vn" target="_blank" class="block px-4 py-3 border-b border-N-200">
                  Đăng nhập <span class="text-Brand-MG font-smb">Kafi Wealth</span>
                </a>
                <span class="block px-4 py-3" style="color: #CBD5E1">
                  Đăng nhập Phái Sinh
                </span>
              </:item>
            </.dropdown>
            <img
              src="/assets/images/header/ic-menu.svg"
              phx-click={
                JS.add_class("show",
                  to: "#modal--menu"
                )
                |> JS.add_class("overflow-hidden", to: "body")
              }
              alt=""
            />
          </div>
        </div>
      </div>
    </header>
    """
  end

  @doc """
  Renders a file pdf.

  ## Examples
    <.no_data />
  """
  attr(:label, :string)
  attr(:label_link, :string, default: nil)
  attr(:on_click, :string, default: nil)

  def no_data(assigns) do
    ~H"""
    <div class="core_data--empty">
      <img class="data-empty__img" src="/assets/images/icon/ic--no-data.svg" alt="" />
      <p class="data-empty__label"><%= assigns[:label] || gettext("Không có dữ liệu") %></p>
      <p class="data-empty__info" phx-click={@on_click}><%= @label_link %></p>
    </div>
    """
  end

  @doc ~S"""
  Renders a table with generic styling.

  ## Examples

      <.table id="users" rows={@users}>
        <:col :let={user} label="id"><%= user.id %></:col>
        <:col :let={user} label="username"><%= user.username %></:col>
      </.table>
  """
  attr(:size, :string, default: "full", values: ~w"full lg xl 2xl 3xl 4xl")
  attr(:id, :string, required: true)
  attr(:rows, :list, required: true)
  attr(:class, :string, default: nil)
  attr(:row_id, :any, default: nil, doc: "the function for generating the row id")
  attr(:on_row_click, :any, default: nil, doc: "the function for handling phx-click on each row")

  attr(:row_item, :any,
    default: &Function.identity/1,
    doc: "the function for mapping each row before calling the :col and :action slots"
  )

  slot(:no_data) do
    attr(:label, :string)
  end

  slot :col, required: true do
    attr(:label, :string)
    attr(:width, :integer)
    attr(:class, :string)
  end

  slot :action, doc: "the slot for showing user actions in the last table column" do
    attr(:label, :string)
    attr(:width, :integer)
  end

  def table(assigns) do
    assigns =
      with %{rows: %Phoenix.LiveView.LiveStream{} = stream} <- assigns do
        assigns
        |> assign(row_id: assigns.row_id || fn {id, _item} -> id end)
        |> assign(empty?: Enum.empty?(stream.inserts))
      else
        _ ->
          assign(assigns, empty?: Enum.empty?(assigns[:rows]))
      end

    ~H"""
    <div class={["overflow-y-auto px-4 sm:overflow-visible sm:px-0", @class]}>
      <table class={["core_table core_table--#{@size}"]}>
        <colgroup span="1">
          <%= for col <- @col do %>
            <col width={if col[:width] == nil, do: "#{100 / length(@col)}%", else: "#{col.width}%"} />
          <% end %>
          <%= for action <- @action do %>
            <col width={"#{action[:width] || 6}%"} />
          <% end %>
        </colgroup>
        <thead>
          <tr>
            <th :for={col <- @col} class={col[:class]}><%= col[:label] %></th>
            <th :if={!Enum.empty?(@action)}></th>
          </tr>
        </thead>

        <tbody id={@id} phx-update={match?(%Phoenix.LiveView.LiveStream{}, @rows) && "stream"}>
          <tr
            :for={row <- @rows}
            id={@row_id && @row_id.(row)}
            phx-click={if(assigns[:on_row_click], do: @on_row_click.(row))}
          >
            <td :for={{col, _i} <- Enum.with_index(@col)} class={col[:class]}>
              <%= render_slot(col, @row_item.(row)) %>
            </td>
            <td :if={!Enum.empty?(@action)} class="core_table__col--action">
              <%= render_slot(@action, @row_item.(row)) %>
            </td>
          </tr>
        </tbody>
      </table>
      <%= if @empty? && !Enum.empty?(@no_data), do: render_slot(@no_data) %>
      <.no_data :if={@empty? && Enum.empty?(@no_data)} />
    </div>
    """
  end

  def table_end(assigns) do
    ~H"""
    <span class="text-center text-G-500 text-sm font-medium mx-auto mt-4 block">
      (<%= gettext("Đã đến cuối danh sách") %>)
    </span>
    """
  end

  @doc """
  Renders a data list.

  ## Examples

      <.list>
        <:item title="Title"><%= @post.title %></:item>
        <:item title="Views"><%= @post.views %></:item>
      </.list>
  """
  slot :item, required: true do
    attr(:title, :string, required: true)
  end

  def list(assigns) do
    ~H"""
    <div class="mt-14">
      <dl class="-my-4 divide-y divide-zinc-100">
        <div :for={item <- @item} class="flex gap-4 py-4 sm:gap-8">
          <dt class="w-1/4 flex-none text-[0.8125rem] leading-6 text-zinc-500"><%= item.title %></dt>
          <dd class="text-sm leading-6 text-zinc-700"><%= render_slot(item) %></dd>
        </div>
      </dl>
    </div>
    """
  end

  attr(:class, :string, default: "")
  attr(:content, :string, values: ~w"unset auto full")
  attr(:direction, :string, default: "row", values: ~w"col row")
  attr(:transparent, :boolean, default: false)
  slot(:inner_block)

  def button_group(assigns) do
    ~H"""
    <div class={[
      "core_btn_group",
      "core_btn_group--#{@direction}",
      if(assigns[:content], do: "core_btn_group--content-#{@content}"),
      if(@transparent, do: "core_btn_group--transparent"),
      @class
    ]}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  @doc """
  Renders a back navigation link.

  ## Examples
      <.grid></.grid>
  """

  attr(:col_span, :integer, default: 1)
  attr(:cols, :integer, default: 1)
  attr(:gap, :integer, default: 4)
  attr(:rows, :integer, default: 1)
  attr(:rest, :global)
  attr(:class, :string, default: nil)
  slot(:inner_block)

  def grid(assigns) do
    ~H"""
    <div
      class={[
        "core_grid",
        if(@cols, do: "core_grid--cols-#{@cols}"),
        if(@col_span, do: "core_grid--colspan-#{@col_span}"),
        if(@gap, do: "core_grid--gap-#{@gap}"),
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  @doc """
  Renders a back navigation link.

  ## Examples

      <.back navigate={~p"/posts"}>Back to posts</.back>
  """
  attr(:navigate, :any, required: true)
  slot(:inner_block, required: true)

  def back(assigns) do
    ~H"""
    <div class="mt-16">
      <.link
        navigate={@navigate}
        class="text-sm font-semibold leading-6 text-zinc-900 hover:text-zinc-700"
      >
        <Heroicons.arrow_left solid class="w-3 h-3 stroke-current inline" />
        <%= render_slot(@inner_block) %>
      </.link>
    </div>
    """
  end

  ## JS Commands

  def show(js \\ %JS{}, selector) do
    JS.show(js,
      to: selector,
      transition:
        {"transition-all transform ease-out duration-300",
         "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95",
         "opacity-100 translate-y-0 sm:scale-100"}
    )
  end

  def hide(js \\ %JS{}, selector) do
    JS.hide(js,
      to: selector,
      time: 200,
      transition:
        {"transition-all transform ease-in duration-200",
         "opacity-100 translate-y-0 sm:scale-100",
         "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"}
    )
  end

  def show_modal(js \\ %JS{}, id) when is_binary(id) do
    js
    |> JS.show(to: "##{id}")
    |> JS.show(
      to: "##{id}-bg",
      transition: {"transition-all transform ease-out duration-300", "opacity-0", "opacity-100"}
    )
    |> show("##{id}-container")
    |> lock_body()
    |> JS.focus_first(to: "##{id}-content")
  end

  def hide_modal(js \\ %JS{}, id) do
    js
    |> JS.hide(
      to: "##{id}-bg",
      transition: {"transition-all transform ease-in duration-200", "opacity-100", "opacity-0"}
    )
    |> hide("##{id}-container")
    |> unlock_body()
    |> JS.hide(to: "##{id}", transition: {"block", "block", "hidden"})
    |> JS.pop_focus()
  end

  def lock_body(js \\ %JS{}) do
    JS.add_class(js, "overflow-hidden", to: "body")
  end

  def unlock_body(js \\ %JS{}) do
    JS.remove_class(js, "overflow-hidden", to: "body")
  end

  def remove_dropdown(js \\ %JS{}, to) do
    JS.remove_class(js, "core_dropdown--active", to: to)
  end

  def navigate(js \\ %JS{}, to) do
    js
    |> JS.remove_class("overflow-hidden", to: "body")
    |> JS.navigate(to)
  end

  @doc """
  Renders a full-view modal that covers the entire page.

  ## Examples

      <.full_view_modal id="confirm-modal">
        Are you sure?
        <:confirm>OK</:confirm>
        <:cancel>Cancel</:cancel>
      </.full_view_modal>
  """
  attr(:id, :string, required: true)
  attr(:show, :boolean, default: false)
  attr(:on_cancel, JS, default: %JS{})

  slot(:inner_block, required: true)
  slot(:title)
  slot(:subtitle)
  slot(:cancel)

  def full_view_modal(assigns) do
    ~H"""
    <div
      id={@id}
      phx-mounted={@show && show_modal(@id)}
      phx-remove={hide_modal(@id)}
      class="relative z-50 hidden"
    >
      <div
        class="fixed inset-0 overflow-y-auto bg-zinc-200 min-h-full"
        aria-labelledby={"#{@id}-title"}
        aria-describedby={"#{@id}-description"}
        role="dialog"
        aria-modal="true"
        tabindex="0"
      >
        <div class="w-full bg-white" id={"#{@id}-header"}>
          <header :if={@title != []} class="max-w--xl mx-auto p-6 relative">
            <.button
              :if={assigns[:on_cancel]}
              phx-click={@on_cancel}
              class="bg-zinc-100 text-black opacity-50 rounded-full px-2 py-2 float-right hover:bg-zinc-100 hover:text-black hover:opacity-100"
            >
              <Heroicons.x_mark class="w-4 h-4" />
            </.button>
            <h1 id={"#{@id}-title"} class="text-lg font-semibold leading-8 text-zinc-800">
              <%= render_slot(@title) %>
            </h1>
            <p
              :if={@subtitle != []}
              id={"#{@id}-description"}
              class="mt-2 text-sm leading-6 text-zinc-600"
            >
              <%= render_slot(@subtitle) %>
            </p>
          </header>
        </div>

        <div
          class="w-full max-w-xl p-6 mx-auto"
          id={"#{@id}-container"}
          phx-mounted={@show && show_modal(@id)}
          phx-window-keydown={hide_modal(@on_cancel, @id)}
          phx-key="escape"
          class="hidden relative rounded-2xl bg-white p-14 shadow-lg shadow-zinc-700/10 ring-1 ring-zinc-700/10 transition"
        >
          <%= render_slot(@inner_block) %>
        </div>
      </div>
    </div>
    """
  end

  attr(:id, :any, required: true)
  slot(:inner_block)

  def page_modal(assigns) do
    ~H"""
    <div
      id={@id}
      class="modal--page"
      phx-remove={
        JS.hide(unlock_body(),
          transition:
            {"transition duration-10000", "translate-x-0 opacity-100", "translate-x-full opacity-0"}
        )
      }
    >
      <div
        id={"#{@id}_wrapper"}
        hidden
        phx-mounted={
          JS.show(lock_body(),
            transition:
              {"transition duration-30000", "translate-x-full opacity-0", "translate-x-0 opacity-100"}
          )
        }
      >
        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end

  attr(:id, :string, required: true)
  attr(:full, :boolean, default: true)
  attr(:tooltip, :boolean, default: false)
  attr(:class, :string, default: nil)
  attr(:container, :string, default: nil)

  attr(:placement, :string,
    default: "bottom-left",
    values: ~w"bottom-left bottom-right top-left top-right top-center"
  )

  slot(:items)

  slot(:item) do
    attr(:on_click, JS)
  end

  slot :label, required: true do
    attr(:class, :string)
  end

  @doc """
  Renders a status.

  ## Examples
    <.dropdown id="dropdown">
      <:label>{@label}</:label>
      <:item>{@item1}</:item>
      <:item>{@item2}</:item>
    </.dropdown>
  """

  def dropdown(assigns) do
    ~H"""
    <div class={["core_dropdown", @class]} id={@id}>
      <div
        :for={label <- @label}
        class={["core_dropdown__title", label[:class]]}
        phx-click={
          JS.add_class("core_dropdown--active",
            to: "##{assigns[:container] || @id}:not(.core_dropdown--active)"
          )
          |> JS.remove_class("core_dropdown--active",
            to: "##{assigns[:container] || @id}.core_dropdown--active"
          )
        }
      >
        <%= render_slot(label) %>
      </div>
      <ul
        id={"#{@id}-list"}
        class={[
          "core_dropdown__list",
          if(@tooltip) do
            "bg-black"
          else
            "bg-white"
          end,
          if(@full, do: "w-full")
        ]}
        phx-click-away={
          JS.remove_class("core_dropdown--active", to: "##{assigns[:container] || @id}")
        }
        data-placement={@placement}
      >
        <%= if !Enum.empty?(@items) do %>
          <%= render_slot(@items) %>
        <% else %>
          <%= for item <- @item do %>
            <li class="item" phx-click={
              item[:on_click]
              }
              ><%= render_slot(item) %></li>
          <% end %>
        <% end %>
      </ul>
    </div>
    """
  end

  @doc """
  Renders a .
  ## Examples
  """
  attr(:class, :string, default: nil)

  attr(:placement, :string,
    default: "bottom-left",
    values: ~w"bottom-left bottom-right top-left top-right top-per-right"
  )

  slot :label, required: true do
    attr(:class, :string)
  end

  slot :content, required: true do
    attr(:class, :string)
  end

  def tooltip(assigns) do
    ~H"""
    <div class={["core_tooltip", @class]}>
      <div :for={label <- @label} class={["core_tooltip__title", label[:class]]}>
        <%= render_slot(label) %>
      </div>
      <div
        :for={content <- @content}
        data-placement={@placement}
        class={["core_tooltip__content", content[:class]]}
      >
        <%= render_slot(content) %>
      </div>
    </div>
    """
  end

  @doc """
  Renders a collapse.
  ## Examples
     <.collapse id="collapse_info">
      <:title><%= @title %></:title>
      <:content><%= @content %></:content>
    </.collapse>
  """

  slot(:title)
  slot(:content)
  attr(:show, :boolean, default: false)
  attr(:id, :string, required: true)
  attr(:rest, :global, include: "class style phx-hook")
  attr(:icon, :string, default: "")

  def collapse(assigns) do
    ~H"""
    <div id={"#{@id}"} class={["core_collapse", if(@show, do: "core_collapse--show"), @rest[:class]]} {@rest}>
      <div
        class="core_collapse__title"
        phx-click={
          JS.remove_class("core_collapse--show", to: "##{@id}.core_collapse--show")
          |> JS.add_class("core_collapse--show", to: "##{@id}:not(.core_collapse--show)")
        }
      >
        <%= render_slot(@title) %>

        <%= if @icon == "add" do %>
          <svg class="icon add"
            width="32"
            height="32" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
            <path fill-rule="evenodd" clip-rule="evenodd" d="M5 12C5 11.4477 5.44772 11 6 11H18C18.5523 11 19 11.4477 19 12C19 12.5523 18.5523 13 18 13H6C5.44772 13 5 12.5523 5 12Z" fill="#A3A3A3"/>
            <path fill-rule="evenodd" clip-rule="evenodd" d="M12 5C12.5523 5 13 5.44772 13 6V18C13 18.5523 12.5523 19 12 19C11.4477 19 11 18.5523 11 18V6C11 5.44772 11.4477 5 12 5Z" fill="#A3A3A3"/>
          </svg>
        <% else %>
          <svg
            class="icon"
            width="32"
            height="32"
            viewBox="0 0 32 32"
            fill="none"
            xmlns="http://www.w3.org/2000/svg"
          >
            <path
              fill-rule="evenodd"
              clip-rule="evenodd"
              d="M13.5017 11.2002C14.8779 9.82391 17.1221 9.82391 18.4984 11.2002L25.7428 18.4446C26.2635 18.9653 26.2635 19.8095 25.7428 20.3302C25.2221 20.8509 24.3779 20.8509 23.8572 20.3302L16.6128 13.0858C16.2779 12.7509 15.7221 12.7509 15.3873 13.0858L8.14284 20.3302C7.62214 20.8509 6.77792 20.8509 6.25722 20.3302C5.73652 19.8095 5.73652 18.9653 6.25722 18.4446L13.5017 11.2002Z"
              fill="#101820"
            />
          </svg>
        <% end %>
      </div>
      <div class="core_collapse__content">
        <%= render_slot(@content) %>
      </div>
    </div>
    """
  end

  slot(:title)
  slot(:content)
  attr(:show, :boolean, default: false)
  attr(:id, :string, required: true)
  attr(:rest, :global, include: "class style phx-hook")
  attr(:icon, :string, default: "")

  def collapse_item(assigns) do
    ~H"""
    <div id={"#{@id}"} class={["core_collapse", @rest[:class]]} {@rest}>
      <div class="core_collapse__title">
        <%= render_slot(@title) %>
        <span class="collapse--item__icon add">+</span>
        <span class="collapse--item__icon minus">-</span>
      </div>
      <div class="core_collapse__content">
        <%= render_slot(@content) %>
      </div>
    </div>
    """
  end

  @doc """
  Renders a collapse.
  ## Examples
     <.collapse id="collapse_info">
      <:title><%= @title %></:title>
      <:content><%= @content %></:content>
    </.collapse>
  """
  attr(:class, :string, default: nil)
  attr(:size, :string, default: nil)
  slot(:content)
  slot(:backgroup)

  def banner_item(assigns) do
    ~H"""
    <div class={[if(@size ) do "banner__item_#{@size}" else "banner__item" end, @class]}>
      <div class="banner__bg">
        <%= render_slot(@backgroup) %>
      </div>
      <div class="banner__content">
        <%= render_slot(@content) %>
      </div>
    </div>
    """
  end

  @doc """
  Renders a data tab.

  ## Examples

      <.tab>
        <:item title="Title"><%= @post.title %></:item>
        <:item title="Views"><%= @post.views %></:item>
      </.tab>
  """

  attr(:tabs, :list, default: [])
  attr(:tab_value, :any, default: &Function.identity/1)
  attr(:class, :string, default: nil)
  attr(:style, :string, default: nil)
  attr(:on_tab_click, :any)
  attr(:"phx-target", :any)
  attr(:active_tab, :any)

  slot(:item)
  slot(:inner_block)

  def tab(assigns) do
    ~H"""
    <div class={@class}>
      <div class="overflow-x-auto mb-8">
        <ul class="menu_tab">
          <li
            :for={tab <- @tabs}
            phx-target={assigns[:"phx-target"]}
            phx-click={assigns[:on_tab_click]}
            phx-value-tab={@tab_value.(tab)}
            class={[
              @style,
              if @tab_value.(tab) == assigns[:active_tab] do
                "active"
              end
            ]}
          >
            <%= render_slot(@item, tab) %>
          </li>
        </ul>
      </div>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  def spinner(assigns) do
    ~H"""
    <Heroicons.arrow_path class="ml-1 w-3 h-3 inline animate-spin" />
    """
  end

  attr(:content, :string, default: nil)
  attr(:class, :string, default: nil)
  attr(:rest, :global, include: "phx-click")

  def link_effect(assigns) do
    ~H"""
      <li class={["link_effect", @class]} {@rest}>
        <%= @content %>
        <img class="icon-effect" src="/assets/images/icon/chevron-right-effect.svg" alt="">
      </li>
    """
  end
end
