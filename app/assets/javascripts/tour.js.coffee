$(".show_global_tour").ready ->

  tour = new Tour({
    storage: false
    container: '#page-content'
    steps: [
      {
        element: ".new_register"
        title: "Create your register"
        content: "Here you can create your register, which you need to view your energy-related data. "
        placement: "top"
      },
      {
        element: ".find_and_join_group"
        title: "Find and join a group"
        content: "After you have created your register, you are able to join a group which you like. Or if you produce energy you can create your own group!"
        placement: "top"
      }
    ]
  })

  #tour.init()

  #tour.start()

$(".show_meter_tour").ready ->
  tour = new Tour({
    storage: false
    container: '#page-content'
    steps: [
      {
        element: ".new_meter"
        title: "Create a Meter"
        content: "Here you can create your Meter, which you need to view your energy-related data. "
        placement: "top"
      }
    ]
  })

  #tour.init()

  #tour.start()