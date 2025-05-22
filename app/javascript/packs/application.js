// import "@hotwired/turbo-rails";
// import "controllers";

// $(document).ready(function () {
//   const $picker = $("#report-daterange");
//   if ($picker.data("daterangepicker")) {
//     $picker.data("daterangepicker").remove();
//   }

//   $picker.daterangepicker(
//     {
//       locale: { format: "YYYY-MM-DD" },
//       opens: "right",
//       autoApply: true,
//     },
//     function (start, end) {
//       $.ajax({
//         url: "/reports/fetch",
//         method: "GET",
//         data: {
//           start_date: start.format("YYYY-MM-DD"),
//           end_date: end.format("YYYY-MM-DD"),
//         },
//         success: function (response) {
//           $("#report-results").html(response);
//         },
//         error: function () {
//           alert("Failed to fetch report. Please try again.");
//         },
//       });
//     }
//   );
// });
