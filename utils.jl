using Dates

function get_all_blog_posts()
    first_year = globvar(:first_blog_year)
    this_year = year(Dates.today())
    all_posts = Dict()
    for year in this_year:-1:first_year
        ys = "$year"
	base = joinpath("blog", ys)
	isdir(base) || continue
        all_posts[ys] = Dict()
        for month in 12:-1:1
            ms = "0"^(month < 10) * "$month"
            # eg blog/2019/09
            base = joinpath("blog", ys, ms)
            # skip if doesn't exist
            isdir(base) || continue
            # get all MD files
            posts = filter!(p -> endswith(p, ".md"), readdir(base))
            isempty(posts) && continue
            # sort by pubdate if there is one
            dates = zeros(Date, length(posts))
            for (i, post) in enumerate(posts)
                posts[i] = rpath = joinpath(base, splitext(post)[1])
                pubdate = pagevar(rpath, :published)
                isnothing(pubdate) && (pubdate = Date(year, month, 1))
                dates[i] = pubdate
            end
            Π = sortperm(dates, rev=true)
            all_posts[ys][ms] = posts[Π] .=> dates[Π]
        end
    end
    return all_posts
end

function hfun_blog_calendar()
    all_posts = get_all_blog_posts()
    io = IOBuffer()
    write(io, """<ul class="taxonomy-index">""")
    for ys in keys(all_posts)
        yc = sum(length(all_posts[ys][ms]) for ms in keys(all_posts[ys]))
        write(io, """
            <li>
              <a href="#$ys">
                <strong>$ys</strong>
                <span class="taxonomy-count">$yc</span>
              </a>
            </li>
            """)
    end
    write(io, """</ul>""")
    return String(take!(io))
end

str(v) = ifelse(isnothing(v), "", v)

function posts_per_year(year_posts)
    post_entries = String[]
    for (_, posts_list) in year_posts
        for (post, date) in posts_list
            post_short = str(pagevar(post, :short))
            post_title = str(pagevar(post, :title))
            push!(post_entries, """
                <article class="entry h-entry">
                  <header class="entry-header">
                    <h3 class="entry-title p-name">
                      <a href="/$post" rel="bookmark">$post_title</a>
                    </h3>
                  </header>
                  <div class="entry-excerpt p-summary">
                    $(Franklin.fd2html(post_short, internal=true))
                  </div>
                  <footer class="entry-meta">
                    <!-- <span class="read-time">~1 min read</span> -->
                    <time class="entry-date dt-published" datetime="$date">$date</time>
                  </footer>
                </article>
                """)
        end
    end
    return post_entries
end

function hfun_blog_calendar_list()
    all_posts = get_all_blog_posts()
    io = IOBuffer()
    for ys in keys(all_posts)
        write(io, """
            <section id="$ys" class="taxonomy-section">
              <h2 class="taxonomy-title">$ys</h2>
              <div class="entries-list">
            """)
        write(io, prod(posts_per_year(all_posts[ys])))
        write(io, """
              </div> <!-- entries list -->
              <a href="#page-title" class="back-to-top">Back to Top &uarr;</a>
            </section>
            """)
    end
    return String(take!(io))
end


function blog_list()
    all_posts = [posts_per_year(year_posts) for year_posts in values(get_all_blog_posts())]
    return vcat(all_posts...)
end

# function hfun_home_pagination()
#     name = locvar(:paginate_itr)
#     isnothing(name) && return ""
#     iter    = locvar(name)
#     npp     = locvar(:paginate_npp)
#     niter   = length(iter)
#     n_pages = ceil(Int, niter / npp)
#     io      = IOBuffer()
#     for (i, pg) in zip(vcat([1, 1], 2:n_pages),
#                        vcat(["index.html"], ["/$i/index.html" for i in 1:n_pages]))
#         write(io, """
#             {{ispage $pg}}
#               <nav class="pagination">
#                 <ul>
#             """)
#         # PREVIOUS ------------------------------------------------------------
#         if i == 1
#             write(io, """
#                 <li><a href="#" class="disabled"><span aria-hidden="true">Previous</span></a></li>
#                 """)
#         else
#             write(io, """
#                 <li><a href="/$(i-1)/">Previous</a></li>
#                 """)
#         end
#         for j = 1:i-1
#             write(io, """
#                 <li><a href="/$j/">$j</a></li>
#                 """)
#         end
#         # CURRENT -------------------------------------------------------------
#         write(io, """
#             <li><a href="#" class="disabled current">$i</a></li>
#             """)
#         for j = i+1:n_pages
#             write(io, """
#                 <li><a href="/$j/">$j</a></li>
#                 """)
#         end
#         # NEXT ----------------------------------------------------------------
#         if i == n_pages
#             write(io, """
#                 <li><a href="#" class="disabled"><span aria-hidden="true">Next</span></a></li>
#                 """)
#         else
#             write(io, """
#                 <li><a href="/$(i+1)/">Next</a></li>
#                 """)
#         end
#         # DONE ----------------------------------------------------------------
#         write(io, """
#                     </ul>
#                   </nav>
#                 {{end}}
#                 """)
#     end
#     return String(take!(io))
# end
