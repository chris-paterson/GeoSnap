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
                  <button type="submit" onclick="allowItem(this)" data-id="{{ $comment->getObjectId() }}" class="btn btn-default">Allow</button>
                  <button type="button" class="btn btn-danger">Delete</button>
                </td>
              </tr>
            @endforeach
          </tbody>
        </table>
      </div>


      <div role="tabpanel" class="tab-pane" id="posts">
        <table id="reported-posts" width="100%">
          <thead>
            <tr>
              <th>Photo</th>
              <th>Action</th> <!-- Delete/Not offensive -->
            </tr>
          </thead>
          <tbody>
            @foreach($posts as $post)
              <tr>
                <td>
                  <a onclick="setModalImage(this)" href="" data-toggle="modal" data-target="#photo-modal" data-src="{{ $post->get('photo')->getURL() }}">
                    <img src="{{ $post->get('photo')->getURL() }}" height="64px" />
                  </a>
                </td>
                <td>
                  <button type="button" onclick="allowItem(this)" data-id="{{ $post->getObjectId() }}" class="btn btn-default">Allow</button>
                  <button type="button" class="btn btn-danger">Delete Item</button>
                </td>
              </tr>
            @endforeach
          </tbody>
        </table>
      </div>
    </div>
  </div>

  <!-- Modal -->
  <div class="modal fade" id="photo-modal" tabindex="-1" role="dialog">
    <div class="modal-dialog modal-lg" role="document">
      <div class="modal-content">
        <div class="modal-header">
          <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
        </div>
        <div class="modal-body">
          <img id="photo-modal-image" src="" width="100%" height="100%"/>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
        </div>
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
    $('#reported-posts').DataTable({"bSort" : false, bFilter: false, "bLengthChange": false});
    $('#reported-comments').DataTable({"bSort" : false, bFilter: false, "bLengthChange": false,});
    
    $('#comments').click(function (e) {
      e.preventDefault()
      $(this).tab('show')
    });

    $('#posts').click(function (e) {
      e.preventDefault()
      $(this).tab('show')
    });

    $('#photo-modal').modal({
      show: false
    });
  });

  function setModalImage(element) {
    $('#photo-modal-image').attr("src", element.getAttribute('data-src'));
  }

    function allowItem(element) {
      $.ajax({
        type: "POST",
        url: "{{ route('allow-item') }}",
        data: {
          objectId: element.getAttribute("data-id"),
        }
      }).done(function(msg) {
        element.closest("tr").remove();
      })
    }
  </script>
@stop