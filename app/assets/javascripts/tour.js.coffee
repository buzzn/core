$(".show_global_tour").ready ->

  tour = new Tour({
    storage: false
    steps: [
      {
        element: ".new_metering_point",
        title: "Create your Metering Point",
        content: "Here you can create your Metering Point, which you need to view your energy-related data. ",
        placement: "top"
      },
      {
        element: ".find_and_join_group",
        title: "Find and join a group",
        content: "After you have created your Metering Point, you are able to join a group which you like. Or if you produce energy you can create your own group!",
        placement: "top"
      }
    ]
  })

  tour.init()

  tour.start()