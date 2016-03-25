@extends('master')
@section('body')
  <h1>Reported items</h1>

  <div>
    <!-- Nav tabs -->
    <ul class="nav nav-tabs" role="tablist">
      <li role="presentation" class="active"><a href="#comments" aria-controls="comments" role="tab" data-toggle="tab">Comments</a></li>
      <li role="presentation"><a href="#posts" aria-controls="posts" role="tab" data-toggle="tab">Posts</a></li>
    </ul>

    <!-- Tab panes -->
    <div class="tab-content">
      <div role="tabpanel" class="tab-pane active" id="comments">
        <table id="reported-comments">
          <thead>
            <tr>
              <th>Comment</th>
              <th>Action</th> <!-- Delete/Not offensive -->
            </tr>
          </thead>
          <tbody>
            @foreach($comments as $comment)
              <tr>
                <td>{{{ $comment->get('comment') }}}</td>
                <td>
                  <button type="button" class="btn btn-default">It's Fine</button>
                  <button type="button" class="btn btn-danger">Delete Item</button>
                </td>
              </tr>
            @endforeach
          </tbody>
        </table>
      </div>


      <div role="tabpanel" class="tab-pane" id="posts">
        <table id="reported-posts">
          <thead>
            <tr>
              <th>Photo</th>
              <th>Action</th> <!-- Delete/Not offensive -->
            </tr>
          </thead>
          <tbody>
            @foreach($posts as $post)
              <tr>
                <td><img src="{{ $post->get('photo')->getURL() }}" width="64" height="64"></td>
                <td>
                  <button type="button" class="btn btn-default">It's Fine</button>
                  <button type="button" class="btn btn-danger">Delete Item</button>
                </td>
              </tr>
            @endforeach
          </tbody>
        </table>
      </div>
    </div>

  </div>



@stop

@section('javascript')
  <script src="//code.jquery.com/jquery-1.12.0.min.js"></script>
  <script src="https://cdn.datatables.net/1.10.11/js/jquery.dataTables.min.js"></script>
  <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/js/bootstrap.min.js" integrity="sha384-0mSbJDEHialfmuBBQP6A4Qrprq5OVfW37PRR3j5ELqxss1yVqOtnepnHVP9aJ7xS" crossorigin="anonymous"></script>

  <script type="text/javascript">
  $(document).ready(function() {
    $('#reported-posts').DataTable();
    $('#reported-comments').DataTable();
    
    $('#comments').click(function (e) {
      e.preventDefault()
      $(this).tab('show')
    });

    $('#posts').click(function (e) {
      e.preventDefault()
      $(this).tab('show')
    });
  });
  </script>
@stop