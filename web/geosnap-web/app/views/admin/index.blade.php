@extends('master')
@section('body')
  <h1>Reported items</h1>
  <table id="reported-items">
    <thead>
      <tr>
        <th>Reported Item</th>
        <th>Type</th>
        <th>Action</th> <!-- Delete/Not offensive -->
      </tr>
    </thead>
    <tbody>
      @foreach($reportedItems as $item)
        <tr>
          <td>{{{ $item->getObjectId() }}}</td>
          <td>{{{ $item->get('class') }}}</td>
          <td>
            <button type="button" class="btn btn-default">It's Fine</button>
            <button type="button" class="btn btn-danger">Delete Item</button>
          </td>
        </tr>
      @endforeach
    </tbody>
  </table>
@stop

@section('javascript')
  <script src="//code.jquery.com/jquery-1.12.0.min.js"></script>
  <script src="https://cdn.datatables.net/1.10.11/js/jquery.dataTables.min.js"></script>
  <script type="text/javascript">
    $(document).ready(function() {
        $('#reported-items').DataTable();
    } );

  </script>
@stop