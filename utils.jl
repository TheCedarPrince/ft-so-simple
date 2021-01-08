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
            sort!(posts, by=dates, rev=true)
            all_posts[ys][ms] = posts
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

function hfun_blog_list()
    # <section id="2018" class="taxonomy-section">
    # <h2 class="taxonomy-title">2018</h2>
    # <div class="entries-list">
    #
    #   <article class="entry h-entry">
    #     <header class="entry-header">
    #       <h3 class="entry-title p-name">
    #         <a href="/so-simple-theme/hidden-post/" rel="bookmark">Hidden Post
    #         </a>
    #       </h3>
    #     </header>
    #
    #     <div class="entry-excerpt p-summary">
    #       <p>This post has YAML Front Matter of <code class="language-plaintext highlighter-rouge">hidden: true</code> and should not appear in <code class="language-plaintext highlighter-rouge">paginator.posts</code>.</p>
    #     </div>
    #
    #     <footer class="entry-meta">
    #       <span class="read-time">~1 min read</span>
    #       <time class="entry-date dt-published" datetime="2018-02-25T00:00:00+00:00">February 25, 2018
    #       </time>
    #     </footer>
    #   </article>
    #
    #   <!-- Add another article here if multiple -->
    #
    # </div>
    # <a href="#page-title" class="back-to-top">Back to Top &uarr;</a>
    # </section>
    return ""
end
