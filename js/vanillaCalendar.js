var vanillaCalendar = {
  month: document.querySelectorAll('[data-calendar-area="month"]')[0],
  next: document.querySelectorAll('[data-calendar-toggle="next"]')[0],
  previous: document.querySelectorAll('[data-calendar-toggle="previous"]')[0],
  label: document.querySelectorAll('[data-calendar-label="month"]')[0],
  activeDates: null,
  date: new Date(),
  todaysDate: new Date(),
 
  init: function (options) {
    this.options = options
    this.date.setDate(1)
    this.createMonth()
    this.createListeners()
  },

   createListeners: function () {
    var _this = this
    this.next.addEventListener('click', function () {
      _this.clearCalendar()
      var nextMonth = _this.date.getMonth() + 1
      _this.date.setMonth(nextMonth)
      _this.createMonth()
    })
    // Clears the calendar and shows the previous month
    this.previous.addEventListener('click', function () {
      _this.clearCalendar()
      var prevMonth = _this.date.getMonth() - 1
      _this.date.setMonth(prevMonth)
      _this.createMonth()
    })
  },

  formatDate : function(_date){
    return (_date.getDate()+"").padStart(2,"0")+"/"+((_date.getMonth()+1)+"").padStart(2,"0")+"/"+(_date.getFullYear()+"").padStart(2,"0")
  },

  createDay: function (num, day, year) {
    var newDay = document.createElement('div')
    var dateEl = document.createElement('span')
    dateEl.innerHTML = num
    newDay.className = 'vcal-date'
    newDay.setAttribute('data-calendar-date', this.formatDate(this.date))

    // if it's the first day of the month
    if (num === 1) {
      if (day === 0) {
        newDay.style.marginLeft = (6 * 14.28) + '%'
      } else {
        newDay.style.marginLeft = ((day - 1) * 14.28) + '%'
      }
    }
    
    if ($("input[name^='Dias'][type='hidden'][value='"+this.formatDate(this.date)+"']").length > 0) {
      newDay.classList.add('vcal-date--chosen')
      newDay.setAttribute('data-calendar-status', 'disabled')
    } else if (this.options.disablePastDays && this.date.getTime() <= this.todaysDate.getTime() - 1) {
      newDay.classList.add('vcal-date--disabled')
    } else {
      newDay.classList.add('vcal-date--active')
      newDay.setAttribute('data-calendar-status', 'active')
    }

    if (this.date.toString() === this.todaysDate.toString()) {
      newDay.classList.add('vcal-date--today')
    }

    newDay.appendChild(dateEl)
    this.month.appendChild(newDay)
  },

  dateClicked: function () {
    
    var _this = this

    var indice = $("input[type='text'][name^='Dias']").length;

    this.activeDates = document.querySelectorAll(
      '[data-calendar-status="active"]'
    )

    this.disabledDates = document.querySelectorAll(
      '[data-calendar-status="disabled"]'
    )

    for(var j = 0; j < this.disabledDates.length; j++) {

      this.buttonDelete = document.querySelectorAll(
        '[remove-selected-day="'+this.disabledDates[j].getAttribute('data-calendar-date')+'"]'
      )

      this.disabledDates[j].addEventListener('click', function (event) {
        if (_this.remove) {
          $("#tblDias").append(`<tr>
                                  <td width="15%">
                                    <input type="hidden" name="Dias|${indice}" value="${this.dataset.calendarDate}">
                                    <b>${this.dataset.calendarDate}</b>
                                  </td>
                                  <td>
                                    <input class="form-control" type="text" name="Dias|${indice}" placeholder="Observação">
                                  </td>
                                  <td width="147px">
                                    <div class="btn-group btn-group-toggle" data-toggle="buttons">
                                    <label class="btn btn-sm btn-info">
                                        <input type="checkbox" name="DiasM|${indice}" id="Contato1" value="M" autocomplete="off"> MANHÃ
                                    </label>
                                    <label class="btn btn-sm btn-info">
                                        <input type="checkbox" name="DiasT|${indice}" id="Contato2" value="T" autocomplete="off"> TARDE
                                    </label>
                                    </div>
                                  </td>
                                  <td width="10%">
                                    <button type="button" class="btn btn-sm btn-danger remove-item-subform" remove-selected-day="${this.dataset.calendarDate}" onclick="$(this).parent().parent().remove();removeSelectedDay('${this.dataset.calendarDate}')">
                                      <i class="fa fa-trash"></i>
                                    </button>
                                  </td>
                                </tr>  `);

          _this.removeActiveClass()
          this.classList.remove('vcal-date--selected')
          this.classList.remove('vcal-date--active')
          this.setAttribute('data-calendar-status', 'disabled')
          this.classList.add('vcal-date--chosen')

          _this.remove = false
        }
      })
    }

    for (var i = 0; i < this.activeDates.length; i++) {
      
      this.activeDates[i].addEventListener('click', function (event) {
        
        var picked = document.querySelectorAll(
          '.dias'
        )[0]

        if ($('div[data-calendar-date|="'+this.dataset.calendarDate+'"]').attr('class').search("active") > 0) {

           var picked2 = $("#tblDias").append(`<tr>
                                                <td width="15%">
                                                  <input type="hidden" name="Dias|${indice}" value="${this.dataset.calendarDate}">
                                                  <b>${this.dataset.calendarDate}</b>
                                                </td>
                                                <td>
                                                  <input class="form-control" type="text" name="Dias|${indice}" placeholder="Observação">
                                                </td>
                                                <td width="147px">
                                                  <div class="btn-group btn-group-toggle" data-toggle="buttons">
                                                  <label class="btn btn-sm btn-info">
                                                      <input type="checkbox" name="DiasM|${indice}" id="Contato1" value="M" autocomplete="off"> MANHÃ
                                                  </label>
                                                  <label class="btn btn-sm btn-info">
                                                      <input type="checkbox" name="DiasT|${indice}" id="Contato2" value="T" autocomplete="off"> TARDE
                                                  </label>
                                                  </div>
                                                </td>
                                                <td width="10%">
                                                  <button type="button" class="btn btn-sm btn-danger remove-item-subform" remove-selected-day="${this.dataset.calendarDate}" onclick="$(this).parent().parent().remove();removeSelectedDay('${this.dataset.calendarDate}')">
                                                    <i class="fa fa-trash"></i>
                                                  </button>
                                                </td>
                                              </tr>  `);

          _this.removeActiveClass()
          this.classList.remove('vcal-date--selected')
          this.classList.remove('vcal-date--active')
          this.setAttribute('data-calendar-status', 'disabled')
          this.classList.add('vcal-date--chosen')

          _this.remove = false
        }
        indice++
      })
    }
  },

  removeSelectedDay: function (data) {
    this.remove = true
    $('div [data-calendar-date|="'+data+'"]').removeAttr('class');
    $('div [data-calendar-date|="'+data+'"]').attr('class','vcal-date vcal-date--active'); 
    $('div [data-calendar-date|="'+data+'"]').attr('data-calendar-status','active'); 
  },

  createMonth: function () {
    var currentMonth = this.date.getMonth()
    while (this.date.getMonth() === currentMonth) {
      this.createDay(
        this.date.getDate(),
        this.date.getDay(),
        this.date.getFullYear()
      )
      this.date.setDate(this.date.getDate() + 1)
    }
    // while loop trips over and day is at 30/31, bring it back
    this.date.setDate(1)
    this.date.setMonth(this.date.getMonth() - 1)

    this.label.innerHTML =
    this.monthsAsString(this.date.getMonth()) + ' ' + this.date.getFullYear()
    this.dateClicked()
  },

  monthsAsString: function (monthIndex) {
    return [
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro'
    ][monthIndex]
  },

  clearCalendar: function () {
    vanillaCalendar.month.innerHTML = ''
  },

  removeActiveClass: function () {
    for (var i = 0; i < this.activeDates.length; i++) {
      this.activeDates[i].classList.remove('vcal-date--selected')
    }
  }
}